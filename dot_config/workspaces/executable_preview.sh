#!/usr/bin/env bash
# Preview script for ws workspace picker (used by fzf)

dir="$1"
if [ ! -d "$dir" ]; then echo "Not found: $dir"; exit 0; fi
cd "$dir" || exit 0

RST="\033[0m"
B="\033[1m"
MAUVE="\033[38;2;203;166;247m"
BLUE="\033[38;2;137;180;250m"
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
RED="\033[38;2;243;139;168m"
DIM="\033[38;2;108;112;134m"
PEACH="\033[38;2;250;179;135m"

echo -e "${B}${MAUVE}$(basename "$dir")${RST}"
echo ""

if [ -d .git ] || [ -f .git ]; then
    # ── Branch & status ──
    branch=$(git branch --show-current 2>/dev/null || echo "?")
    echo -e "  ${BLUE}⎇ Branch${RST}     $branch"

    remote_url=$(git remote get-url origin 2>/dev/null || echo "—")
    short_url=$(echo "$remote_url" | sed 's|https://github.com/||;s|git@github.com:||;s|\.git$||')
    echo -e "  ${DIM}⌂ Remote${RST}     $short_url"

    dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$dirty" -gt 0 ]; then
        echo -e "  ${YELLOW}● Dirty${RST}      $dirty files"
    else
        echo -e "  ${GREEN}✓ Clean${RST}"
    fi

    # Ahead/behind
    ab=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [ -n "$ab" ]; then
        ahead=$(echo "$ab" | awk '{print $1}')
        behind=$(echo "$ab" | awk '{print $2}')
        [ "$ahead" -gt 0 ] && echo -e "  ${GREEN}↑ Ahead${RST}      $ahead commits"
        [ "$behind" -gt 0 ] && echo -e "  ${RED}↓ Behind${RST}     $behind commits"
    fi

    # First and last commit timestamps
    first_commit=$(git log --format="%cr" --reverse -1 2>/dev/null)
    if [ -n "$first_commit" ]; then
        echo -e "  ${DIM}◷ First commit${RST} $first_commit"
    fi

    last_commit=$(git log --format="%cr" -1 2>/dev/null)
    if [ -n "$last_commit" ]; then
        echo -e "  ${DIM}◷ Last commit${RST}  $last_commit"
    fi

    echo ""
    echo -e "${DIM}── Recent commits ──${RST}"
    git log --oneline -8 --format="  %C(yellow)%h%C(reset) %s %C(dim)(%cr)%C(reset)" 2>/dev/null

    # Stashes
    stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$stash_count" -gt 0 ]; then
        echo ""
        echo -e "${DIM}── Stashes ($stash_count) ──${RST}"
        git stash list --format="  %C(yellow)%gd%C(reset) %s" 2>/dev/null | head -5
    fi

    echo ""
fi

echo -e "${DIM}── Files ──${RST}"
if command -v eza &>/dev/null; then
    eza --icons -1 --color=always --group-directories-first -a --git-ignore 2>/dev/null | head -20
else
    ls -1A 2>/dev/null | head -20
fi
