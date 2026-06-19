#!/usr/bin/env python3.13
"""ws — Unified workspace switcher.

One fuzzy-searchable list for all projects and worktrees.
Select to open in a kitty tab (pi + terminal + lazygit), or create/remove worktrees.

Usage:
    ws                  Interactive picker (projects + worktrees together)
    ws new              Create a new worktree from a project
    ws rm               Remove a worktree
    ws <query>          Jump directly with fuzzy query

When running inside kitty, opens a new stacked tab with pi, terminal, and lazygit.
Falls back to printing the directory path to stdout otherwise.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path
from time import time

try:
    import tomllib
except ImportError:
    tomllib = None

# ── ANSI helpers (Catppuccin Mocha) ──────────────────────────────────────────

RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
LAVENDER = "\033[38;2;180;190;254m"
BLUE = "\033[38;2;137;180;250m"
GREEN = "\033[38;2;166;227;161m"
YELLOW = "\033[38;2;249;226;175m"
RED = "\033[38;2;243;139;168m"
MAUVE = "\033[38;2;203;166;247m"
OVERLAY = "\033[38;2;108;112;134m"
TEXT = "\033[38;2;205;214;244m"
PEACH = "\033[38;2;250;179;135m"


def styled(text, *styles):
    return "".join(styles) + str(text) + RESET


def info(msg):
    print(styled(f"  {msg}", GREEN), file=sys.stderr)


def warn(msg):
    print(styled(f"  {msg}", YELLOW), file=sys.stderr)


def error(msg):
    print(styled(f"✗ {msg}", RED), file=sys.stderr)


def dim_msg(msg):
    print(styled(f"  {msg}", OVERLAY), file=sys.stderr)


def header(title):
    print("", file=sys.stderr)
    print(styled(f"  {title}", MAUVE, BOLD), file=sys.stderr)
    print("", file=sys.stderr)


# ── Config ───────────────────────────────────────────────────────────────────


@dataclass
class Config:
    workspace_dir: Path = field(
        default_factory=lambda: Path.home() / "Workspace"
    )
    worktree_dir: Path = field(
        default_factory=lambda: Path.home() / "workspace" / "worktrees"
    )
    history_file: Path = field(
        default_factory=lambda: Path.home() / ".config" / "workspaces" / "history.json"
    )
    max_history: int = 100
    exclude: list = field(default_factory=lambda: [".DS_Store", ".pi"])


def load_config() -> Config:
    config_file = Path.home() / ".config" / "workspaces" / "config.toml"
    config = Config()

    if config_file.exists() and tomllib:
        with open(config_file, "rb") as f:
            data = tomllib.load(f)
        if "workspace_dir" in data:
            config.workspace_dir = Path(data["workspace_dir"]).expanduser()
        if "worktree_dir" in data:
            config.worktree_dir = Path(data["worktree_dir"]).expanduser()
        if "max_history" in data:
            config.max_history = data["max_history"]
        if "exclude" in data:
            config.exclude = data["exclude"]

    return config


# ── Git helpers ──────────────────────────────────────────────────────────────


def git(*args, cwd=None, timeout=5):
    """Run a git command and return stdout, or None on failure."""
    try:
        r = subprocess.run(
            ["git", *args],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return r.stdout.strip() if r.returncode == 0 else None
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None


def git_branch(path: Path) -> str:
    """Get current branch name (fast: reads .git/HEAD directly)."""
    head_file = path / ".git" / "HEAD"
    if head_file.is_file():
        content = head_file.read_text().strip()
        if content.startswith("ref: refs/heads/"):
            return content[16:]
        return content[:8] + "…"
    # Worktrees have .git as a file pointing to main repo
    git_file = path / ".git"
    if git_file.is_file():
        result = git("branch", "--show-current", cwd=path)
        if result:
            return result
        result = git("rev-parse", "--short", "HEAD", cwd=path)
        return result or "?"
    return ""


def git_status(path: Path) -> dict:
    """Get git status: branch, dirty count, ahead/behind."""
    result = {"branch": "", "dirty": 0, "ahead": 0, "behind": 0, "last_commit": ""}

    result["branch"] = git_branch(path)

    # Dirty count
    porcelain = git("status", "--porcelain", cwd=path)
    if porcelain:
        result["dirty"] = len(porcelain.splitlines())

    # Ahead/behind upstream
    ab = git("rev-list", "--left-right", "--count", "HEAD...@{upstream}", cwd=path)
    if ab:
        parts = ab.split()
        if len(parts) == 2:
            result["ahead"] = int(parts[0])
            result["behind"] = int(parts[1])

    # Last commit subject
    last = git("log", "--oneline", "-1", "--format=%s", cwd=path)
    if last:
        result["last_commit"] = last[:60]

    return result


# ── History (MRU) ────────────────────────────────────────────────────────────


def load_history(config: Config) -> dict:
    if config.history_file.exists():
        try:
            return json.loads(config.history_file.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    return {}


def save_history(config: Config, path: Path):
    history = load_history(config)
    history[str(path)] = time()

    # Trim oldest
    if len(history) > config.max_history:
        sorted_items = sorted(history.items(), key=lambda x: x[1], reverse=True)
        history = dict(sorted_items[: config.max_history])

    config.history_file.parent.mkdir(parents=True, exist_ok=True)
    config.history_file.write_text(json.dumps(history, indent=2))


# ── Workspace model ──────────────────────────────────────────────────────────


@dataclass
class Workspace:
    name: str
    path: Path
    kind: str  # "project" | "worktree"
    parent: str = ""  # parent project name (for worktrees)
    branch: str = ""
    dirty: int = 0
    ahead: int = 0
    behind: int = 0
    last_commit: str = ""
    last_visited: float = 0.0

    @property
    def display_name(self) -> str:
        if self.kind == "worktree":
            label = self.branch or self.name.split("/")[-1]
            return f"{self.parent} → {label}"
        return self.name

    @property
    def sort_key(self) -> tuple:
        """Recently visited first, then projects before worktrees, then alpha."""
        return (
            -self.last_visited,
            0 if self.kind == "project" else 1,
            self.name.lower(),
        )


def scan_all(config: Config) -> list:
    """Scan projects + worktrees, gather git info in parallel."""
    workspaces: list[Workspace] = []
    seen_paths: set[str] = set()

    # 1. Projects from ~/Workspace
    if config.workspace_dir.is_dir():
        for d in sorted(config.workspace_dir.iterdir()):
            if not d.is_dir():
                continue
            if d.name.startswith(".") or d.name in config.exclude:
                continue
            if d.name == "worktrees":
                continue
            workspaces.append(Workspace(name=d.name, path=d, kind="project"))
            seen_paths.add(str(d.resolve()))

    # 2. Worktrees from ~/workspace/worktrees/<repo>/<branch>
    if config.worktree_dir.is_dir():
        for repo_dir in sorted(config.worktree_dir.iterdir()):
            if not repo_dir.is_dir() or repo_dir.name.startswith("."):
                continue
            for wt_dir in sorted(repo_dir.iterdir()):
                if not wt_dir.is_dir() or wt_dir.name.startswith("."):
                    continue
                resolved = str(wt_dir.resolve())
                if resolved in seen_paths:
                    continue
                seen_paths.add(resolved)
                workspaces.append(
                    Workspace(
                        name=f"{repo_dir.name}/{wt_dir.name}",
                        path=wt_dir,
                        kind="worktree",
                        parent=repo_dir.name,
                    )
                )

    # 3. Load history for recency sorting
    history = load_history(config)

    # 4. Enrich with git info in parallel
    def enrich(ws: Workspace) -> Workspace:
        git_dir = ws.path / ".git"
        if git_dir.exists():
            status = git_status(ws.path)
            ws.branch = status["branch"]
            ws.dirty = status["dirty"]
            ws.ahead = status["ahead"]
            ws.behind = status["behind"]
            ws.last_commit = status["last_commit"]
        ws.last_visited = history.get(str(ws.path), 0.0)
        return ws

    with ThreadPoolExecutor(max_workers=8) as pool:
        workspaces = list(pool.map(enrich, workspaces))

    workspaces.sort(key=lambda w: w.sort_key)
    return workspaces


# ── Formatting ───────────────────────────────────────────────────────────────


def format_workspace_line(ws: Workspace, max_name: int = 40) -> str:
    """Format a workspace for fzf display. Returns: 'display\\tpath'."""
    icon = "📁" if ws.kind == "project" else "🌿"

    name = ws.display_name
    if len(name) > max_name:
        name = name[: max_name - 1] + "…"

    # Git status parts
    parts = []
    if ws.branch:
        parts.append(styled(f"⎇ {ws.branch}", BLUE))
    if ws.dirty > 0:
        parts.append(styled(f"● {ws.dirty}", YELLOW))
    else:
        parts.append(styled("✓", GREEN))
    if ws.ahead > 0:
        parts.append(styled(f"↑{ws.ahead}", GREEN))
    if ws.behind > 0:
        parts.append(styled(f"↓{ws.behind}", RED))

    git_str = "  ".join(parts)

    # Recency star
    recency = ""
    if ws.last_visited > 0:
        age = time() - ws.last_visited
        if age < 3600:
            recency = styled(" ★", YELLOW)
        elif age < 86400:
            recency = styled(" ★", OVERLAY)

    padded = f"{name:<{max_name}}"
    display = f" {icon} {padded}  {git_str}{recency}"

    # Tab-separated: display \t path  (fzf --with-nth=1 hides the path)
    return f"{display}\t{ws.path}"


# ── fzf wrapper ──────────────────────────────────────────────────────────────


def fzf_select(
    items: list[str],
    header: str = "",
    prompt: str = "❯ ",
    query: str = "",
    preview_cmd: str | None = None,
    multi: bool = False,
    expect: str = "",
) -> str | None:
    """Run fzf and return selected line (full, including hidden fields)."""
    cmd = [
        "fzf",
        "--ansi",
        "--reverse",
        "--prompt",
        prompt,
        "--pointer",
        "▸",
        "--delimiter",
        "\t",
        "--with-nth",
        "1",
        "--color",
        "pointer:#b4befe,prompt:#b4befe,hl:#a6e3a1,hl+:#a6e3a1,info:#6c7086,header:#cba6f7",
        "--no-separator",
        "--margin",
        "1,2",
    ]
    if header:
        cmd += ["--header", header]
    if query:
        cmd += ["--query", query]
    if preview_cmd:
        cmd += ["--preview", preview_cmd, "--preview-window", "right:50%:wrap"]
    if multi:
        cmd += ["--multi"]
    if expect:
        cmd += ["--expect", expect]

    try:
        r = subprocess.run(
            cmd,
            input="\n".join(items),
            capture_output=True,
            text=True,
        )
        if r.returncode not in (0, 1):  # 1 = no match / esc, 130 = ctrl-c
            return None
        result = r.stdout.strip()
        return result if result else None
    except FileNotFoundError:
        error("fzf not found — install: brew install fzf")
        sys.exit(1)


def gum_confirm(prompt: str) -> bool:
    """Confirm with gum or fallback to input()."""
    try:
        r = subprocess.run(
            [
                "gum",
                "confirm",
                "--prompt.foreground",
                "#f9e2af",
                prompt,
            ],
            capture_output=True,
        )
        return r.returncode == 0
    except FileNotFoundError:
        print(f"  {prompt} [y/N] ", end="", file=sys.stderr, flush=True)
        try:
            return input().strip().lower() == "y"
        except (EOFError, KeyboardInterrupt):
            return False


def gum_input(prompt: str, placeholder: str = "") -> str | None:
    """Input with gum or fallback to input()."""
    try:
        r = subprocess.run(
            [
                "gum",
                "input",
                "--placeholder",
                placeholder,
                "--prompt",
                prompt,
                "--prompt.foreground",
                "#b4befe",
                "--cursor.foreground",
                "#b4befe",
            ],
            capture_output=True,
            text=True,
        )
        if r.returncode != 0:
            return None
        return r.stdout.strip() or None
    except FileNotFoundError:
        print(styled(f"  {prompt}", LAVENDER), end="", file=sys.stderr, flush=True)
        try:
            val = input().strip()
            return val or None
        except (EOFError, KeyboardInterrupt):
            return None


# ── Preview ──────────────────────────────────────────────────────────────────

PREVIEW_SCRIPT = Path.home() / ".config" / "workspaces" / "preview.sh"


# ── Commands ─────────────────────────────────────────────────────────────────


def _kitty(*args) -> subprocess.CompletedProcess:
    """Run a kitty @ command, raising on failure."""
    kitty_bin = shutil.which("kitty")
    r = subprocess.run(
        [kitty_bin, "@", *args],
        capture_output=True, text=True,
    )
    if r.returncode != 0:
        raise RuntimeError(f"kitty @ {args[0]} failed: {r.stderr.strip()}")
    return r


def open_in_kitty(target: Path):
    """Open a workspace in kitty with split windows: pi (80% left), terminal (20% right)."""
    kitty_pid = os.environ.get("KITTY_PID")
    kitty_bin = shutil.which("kitty")

    if not kitty_pid or not kitty_bin:
        # Not in kitty — just print path for shell to cd
        print(target)
        return

    pi_bin = shutil.which("pi") or str(Path.home() / ".bun" / "bin" / "pi")
    target_str = str(target)

    # Build tab title: "project-name (branch)"
    branch = git_branch(target)
    if branch and branch != target.name:
        tab_title = f"{target.name} ({branch})"
    else:
        tab_title = target.name

    try:
        # Launch pi in a new tab (left pane)
        r = _kitty("launch", "--type=tab",
                    "--tab-title", tab_title,
                    "--title", tab_title,
                    "--cwd", target_str,
                    "zsh", "-lc", f"{pi_bin}; exec zsh -li")
        pi_id = r.stdout.strip()

        # Switch to splits layout
        _kitty("goto-layout", "splits")

        # Launch terminal as a vertical split on the right (20% of space)
        _kitty("launch", "--keep-focus", "--location=vsplit",
               "--bias=20",
               "--title", tab_title, "--cwd", target_str)

        # Focus the pi window
        if pi_id:
            try:
                _kitty("focus-window", "--match", f"id:{pi_id}")
            except RuntimeError:
                try:
                    _kitty("focus-tab", "--match", f"title:{tab_title}")
                except RuntimeError:
                    pass
    except (OSError, RuntimeError) as e:
        error(f"Failed to launch kitty windows: {e}")
        print(target)


def _action_menu(ws: Workspace) -> str | None:
    """Show a contextual action submenu for a workspace. Returns action key or None."""
    name = ws.display_name
    items = [
        f"  {styled('󰏌  Open', GREEN, BOLD)}  │  open in kitty\topen",
    ]
    if ws.kind == "project":
        items.append(
            f"  {styled('  New worktree', BLUE)}  │  clone a branch of {styled(name, LAVENDER)}\tcreate",
        )
    elif ws.kind == "worktree":
        items.append(
            f"  {styled('  New worktree', BLUE)}  │  clone another branch of {styled(ws.parent, LAVENDER)}\tcreate",
        )
        items.append(
            f"  {styled('󰩺  Delete', RED)}  │  remove {styled(name, LAVENDER)}\tdelete",
        )

    selected = fzf_select(
        items,
        header=f"  {styled(name, MAUVE, BOLD)}",
        prompt="  ",
    )
    if not selected:
        return None
    return selected.split("\t")[-1].strip()


def cmd_switch(config: Config, query: str = ""):
    """Unified workspace picker — projects and worktrees in one list.

    On enter, shows a contextual action submenu (open / create worktree / delete).
    Loops back to the picker after creating/deleting worktrees.
    """
    while True:
        workspaces = scan_all(config)

        if not workspaces:
            error("No workspaces found")
            return

        max_name = min(max(len(ws.display_name) for ws in workspaces), 45)

        all_lines = []
        project_lines = []
        worktree_lines = []
        for ws in workspaces:
            line = format_workspace_line(ws, max_name)
            all_lines.append(line)
            if ws.kind == "project":
                project_lines.append(line)
            else:
                worktree_lines.append(line)

        # Write line sets to temp files for fzf --bind reload
        tmpdir = tempfile.mkdtemp(prefix="ws_")
        all_file = os.path.join(tmpdir, "all")
        proj_file = os.path.join(tmpdir, "projects")
        wt_file = os.path.join(tmpdir, "worktrees")

        with open(all_file, "w") as f:
            f.write("\n".join(all_lines))
        with open(proj_file, "w") as f:
            f.write("\n".join(project_lines))
        with open(wt_file, "w") as f:
            f.write("\n".join(worktree_lines))

        header_text = "  enter: actions  │  ctrl-a: all  │  ctrl-p: projects  │  ctrl-t: worktrees"

        cmd = [
            "fzf",
            "--ansi",
            "--reverse",
            "--prompt", "❯ ",
            "--pointer", "▸",
            "--delimiter", "\t",
            "--with-nth", "1",
            "--color", "pointer:#b4befe,prompt:#b4befe,hl:#a6e3a1,hl+:#a6e3a1,info:#6c7086,header:#cba6f7",
            "--no-separator",
            "--margin", "1,2",
            "--header", header_text,
            "--preview", f"bash {_shell_quote(str(PREVIEW_SCRIPT))} {{2}}",
            "--preview-window", "right:50%:wrap",
            "--bind", f"ctrl-a:reload(cat {_shell_quote(all_file)})+change-header({header_text})",
            "--bind", f"ctrl-p:reload(cat {_shell_quote(proj_file)})+change-header(  📁 Projects only  │  ctrl-a: show all)",
            "--bind", f"ctrl-t:reload(cat {_shell_quote(wt_file)})+change-header(  🌿 Worktrees only  │  ctrl-a: show all)",
        ]
        if query:
            cmd += ["--query", query]

        try:
            r = subprocess.run(
                cmd,
                input="\n".join(all_lines),
                capture_output=True,
                text=True,
            )
        finally:
            shutil.rmtree(tmpdir, ignore_errors=True)

        if r.returncode != 0 or not r.stdout.strip():
            return

        selection = r.stdout.strip()

        # Extract path (after tab)
        parts = selection.split("\t")
        if len(parts) < 2:
            return
        target = Path(parts[-1].strip())

        ws = _find_workspace_by_path(workspaces, target)
        if not ws:
            return

        # Show contextual action submenu
        action = _action_menu(ws)

        if action == "open":
            if target.is_dir():
                save_history(config, target)
                info(f"→ {target}")
                open_in_kitty(target)
            query = ""
            continue

        if action == "create":
            if ws.kind == "worktree" and ws.parent:
                project_path = config.workspace_dir / ws.parent
                if project_path.is_dir():
                    _create_worktree(config, project_path, ws.parent)
            else:
                _create_worktree(config, ws.path, ws.name)
            query = ""
            continue

        if action == "delete":
            if ws.kind == "worktree":
                _remove_worktree(config, ws)
            else:
                warn("Can only delete worktrees, not projects")
            query = ""
            continue

        # None / esc in submenu → loop back to picker
        query = ""
        continue


def _shell_quote(s: str) -> str:
    """Quote a string for safe shell embedding."""
    return "'" + s.replace("'", "'\\''") + "'"


def _find_workspace_by_path(workspaces: list, target: Path):
    target_resolved = target.resolve()
    for ws in workspaces:
        if ws.path.resolve() == target_resolved:
            return ws
    return None


def cmd_new(config: Config):
    """Create a new worktree — pick project, then branch."""
    header("🚀 Create Worktree")

    workspaces = scan_all(config)
    projects = [
        ws for ws in workspaces if ws.kind == "project" and (ws.path / ".git").is_dir()
    ]

    if not projects:
        error("No git projects found in ~/Workspace")
        return

    max_name = min(max(len(ws.name) for ws in projects), 45)

    lines = []
    for ws in projects:
        lines.append(format_workspace_line(ws, max_name))

    selected = fzf_select(lines, header="Step 1/3: Pick a repository")
    if not selected:
        return

    parts = selected.split("\t")
    if len(parts) < 2:
        return
    project_path = Path(parts[-1].strip())
    project_name = project_path.name

    _create_worktree(config, project_path, project_name)


def _create_worktree(config: Config, project_path: Path, project_name: str):
    """Clone a repo branch into the worktree directory."""
    # Fetch latest
    dim_msg("Fetching branches…")
    git("fetch", "--prune", cwd=project_path, timeout=15)

    # List branches
    branches_raw = git(
        "branch", "-a", "--format=%(refname:short)", cwd=project_path
    )
    if not branches_raw:
        error("Could not list branches")
        return

    seen = set()
    branches = []
    for b in branches_raw.splitlines():
        b = b.strip()
        if b.startswith("origin/"):
            b = b[7:]
        if b in ("HEAD", "") or b in seen:
            continue
        seen.add(b)
        branches.append(b)

    # Pin main/master/test to top
    pinned = [b for b in branches if b in ("main", "master", "test", "develop")]
    rest = sorted(b for b in branches if b not in pinned)
    branches = pinned + rest

    # Check existing clones in worktree dir
    wt_repo_dir = config.worktree_dir / project_name
    existing_folders = set()
    if wt_repo_dir.is_dir():
        for d in wt_repo_dir.iterdir():
            if d.is_dir():
                existing_folders.add(d.name)

    branch_lines = []
    for b in branches:
        folder = b.replace("/", "_").replace(" ", "_")
        exists = folder in existing_folders
        marker = f"\t[exists]" if exists else "\t"
        display = f"  {b}"
        if exists:
            display = f"  {b} {styled('[exists]', OVERLAY)}"
        branch_lines.append(f"{display}\t{b}")

    selected_branch = fzf_select(
        branch_lines,
        header=f"Step 2/3: Pick a branch ({project_name})",
    )
    if not selected_branch:
        return

    # Extract branch name (after tab)
    branch = selected_branch.split("\t")[-1].strip()

    # Check if clone exists for this branch
    folder = branch.replace("/", "_").replace(" ", "_")
    existing_path = config.worktree_dir / project_name / folder
    if existing_path.is_dir():
        if gum_confirm(f"Clone for '{branch}' already exists. Open it?"):
            save_history(config, existing_path)
            info(f"→ {existing_path}")
            open_in_kitty(existing_path)
        return

    # Step 3: Use existing or create new branch?
    action_lines = [
        f"  {styled('Use this branch', TEXT)}  │  checkout {styled(branch, BLUE)} as-is\tuse",
        f"  {styled('Create new branch', TEXT)}  │  new branch off {styled(branch, BLUE)}\tnew",
    ]
    action_sel = fzf_select(
        action_lines,
        header=f"Step 3/3: Branch action",
    )
    if not action_sel:
        return

    action_key = action_sel.split("\t")[-1].strip()
    target_branch = branch

    if action_key == "new":
        target_branch = gum_input("New branch name: ", "feature/my-feature")
        if not target_branch:
            dim_msg("Aborted: no branch name given")
            return

    # Clone the repo into the worktree directory
    folder = target_branch.replace("/", "_").replace(" ", "_")
    wt_path = config.worktree_dir / project_name / folder
    wt_path.parent.mkdir(parents=True, exist_ok=True)

    remote_url = git("remote", "get-url", "origin", cwd=project_path)
    if not remote_url:
        error("Could not get remote URL")
        return

    dim_msg(f"Cloning {project_name} ({branch})…")
    r = subprocess.run(
        ["git", "clone", "--branch", branch, remote_url, str(wt_path)],
        capture_output=True,
        text=True,
        timeout=120,
    )
    if r.returncode != 0:
        error(f"Clone failed: {r.stderr.strip()}")
        return

    if target_branch != branch:
        git("checkout", "-b", target_branch, cwd=wt_path)

    # Trust mise if present
    mise_toml = wt_path / ".mise.toml"
    if mise_toml.exists():
        subprocess.run(
            ["mise", "trust", str(mise_toml)], capture_output=True
        )
        dim_msg("Trusted mise config")

    info(f"✓ Cloned {project_name}/{folder}")
    save_history(config, wt_path)
    open_in_kitty(wt_path)


def cmd_rm(config: Config):
    """Remove a worktree."""
    header("🗑️  Remove Worktree")

    workspaces = scan_all(config)
    worktrees = [ws for ws in workspaces if ws.kind == "worktree"]

    if not worktrees:
        warn("No worktrees found")
        return

    max_name = min(max(len(ws.display_name) for ws in worktrees), 45)

    lines = []
    wt_map = {}
    for ws in worktrees:
        line = format_workspace_line(ws, max_name)
        lines.append(line)
        wt_map[line.split("\t")[-1].strip()] = ws

    selected = fzf_select(lines, header="Select worktree to remove")
    if not selected:
        return

    target_str = selected.split("\t")[-1].strip()
    ws = wt_map.get(target_str)
    if not ws:
        return

    _remove_worktree(config, ws)


def _remove_worktree(config: Config, ws: Workspace):
    """Remove a cloned worktree directory."""
    cwd = Path.cwd().resolve()
    if cwd == ws.path.resolve():
        error("Cannot delete the workspace you're currently in")
        return

    # Confirm
    warning = ""
    if ws.dirty > 0:
        warning = f" ⚠ {ws.dirty} uncommitted files!"
    prompt = f"Delete {ws.display_name}?{warning}"

    if not gum_confirm(prompt):
        dim_msg("Aborted")
        return

    if ws.path.is_dir():
        shutil.rmtree(ws.path)

    info(f"✓ Deleted {ws.display_name}")

    # Clean up empty parent dir
    parent = ws.path.parent
    if parent.is_dir() and not any(parent.iterdir()):
        parent.rmdir()
        dim_msg(f"Cleaned up empty directory {parent}")


# ── Main ─────────────────────────────────────────────────────────────────────


def main():
    config = load_config()
    args = sys.argv[1:]
    cmd = args[0] if args else ""
    query = " ".join(args[1:]) if len(args) > 1 else ""

    if cmd in ("", "s", "switch"):
        cmd_switch(config, query)
    elif cmd in ("n", "new", "create"):
        cmd_new(config)
    elif cmd in ("r", "rm", "remove", "delete"):
        cmd_rm(config)
    else:
        # Treat as search query
        cmd_switch(config, " ".join(args))


if __name__ == "__main__":
    main()
