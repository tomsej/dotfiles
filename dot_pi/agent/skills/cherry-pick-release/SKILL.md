---
name: cherry-pick-release
description: Create a release branch from main, cherry-pick specific commits from test, and validate the result. Use when preparing a production release by cherry-picking commits, checking scope and parity with the test branch.
---

# Cherry-Pick Release Skill

## Purpose
Create a release branch from `main`, cherry-pick commits from `test`, and validate the result is clean and complete before merging to production.

## Workflow

### 1. Prepare
```bash
git fetch origin
git checkout main && git reset --hard origin/main
```

### 2. Create release branch
```bash
git checkout -b release/<feature-name>
```
Use the feature/ticket name provided by the user.

### 3. Cherry-pick commits
User provides commit SHAs (from `test` branch). Apply them in chronological order:
```bash
git cherry-pick <sha1> <sha2> ...
```
If conflicts arise, **stop and ask the user** — never auto-resolve.

### 4. Validate scope (PR diff check)
Verify the diff against `main` only touches files related to the feature:
```bash
git diff origin/main...HEAD --stat
git diff origin/main...HEAD --name-only
```
- Review the file list. Flag any file that doesn't belong to the feature.
- If unexpected files appear, warn the user — likely a missing dependency or wrong commit.

### 5. Validate parity with test
Ensure cherry-picked changes produce the same result as on `test`. For each changed file, compare the file content on the release branch vs `origin/test`:
```bash
# For each file in the diff:
git diff HEAD:<file> origin/test:<file>
```
- **No diff** = good — change is identical on both branches.
- **Diff exists** = investigate. Possible causes:
  - Missing commit (need more cherry-picks)
  - Commit on `test` was amended/squashed differently
  - File has other unrelated changes on `test` (expected, safe to ignore if only surrounding context differs)
- Report findings to the user with a summary table:

| File | Status | Notes |
|------|--------|-------|
| `module/main.tf` | ✅ identical | |
| `module/variables.tf` | ⚠️ differs | lines X-Y differ, likely unrelated change on test |

### 6. Terraform validation (optional, recommended)
If the change touches Terraform modules:
```bash
make tf-fmt
make plan ENVIRONMENT=test TF_TARGET='module.<name>'
```

### 7. Final summary
Report to the user:
- Branch name and commit count
- Files changed (scoped to feature: yes/no)
- Parity with test (all matching / issues found)
- Ready to push: yes/no

## Key Rules
- **Never force-push** to `main` or `test`.
- **Never auto-resolve** cherry-pick conflicts.
- **Always validate** both scope and parity before declaring ready.
- Commits must be provided by the user — don't guess which commits to pick.
