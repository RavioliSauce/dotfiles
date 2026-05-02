# Git Cheatsheet (Practical)

Related: [Git workflow notes](workflow.md), [Git recovery notes](recovery.md)

Jump to:
[Inspecting History](#inspecting-history) |
[Inspecting Commits](#inspecting-commits) |
[Diffing Changes](#diffing-changes) |
[Daily Flow](#daily-flow) |
[High-Value Tricks](#high-value-tricks) |
[Exploration](#exploration) |
[Cleanup](#cleanup) |
[Recovery Pointers](#recovery-pointers)

## Inspecting History

Related: [safe daily loop](workflow.md#safe-daily-loop), [lost commits](recovery.md#find-lost-commits)

### Basic log
git log

### Clean graph view (default mental model)
git log --oneline --graph --decorate --all

### File history (with diffs)
git log -p path/to/file

### Search commits
git log --grep "search" --regexp-ignore-case

### By author
git log --author="name"

### Between dates
git log --after="2024-01-01" --before="2024-02-01"

---

## Inspecting Commits

Related: [reviewing before commit](workflow.md#reviewing-before-commit), [restore a file from history](recovery.md#restore-a-file-from-history)

### Show latest commit
git show

### Show specific commit
git show <commit>

### One-line commit (no diff)
git show --oneline --no-patch <commit>

### Files changed
git show --name-only <commit>

### Stats (insertions/deletions)
git show --stat <commit>

### File at a specific revision
git show <commit>:path/to/file

---

## Diffing Changes

Related: [reviewing before commit](workflow.md#reviewing-before-commit), [unstage without losing work](recovery.md#unstage-without-losing-work)

### Unstaged changes
git diff

### Staged changes
git diff --staged

### All changes vs last commit
git diff HEAD

### Compare branches
git diff branch1..branch2

### Diff a file between branches
git diff branch1..branch2 path/to/file

### Stats only
git diff --stat

---

## Mental Models

- **Working directory** → your files
- **Staging area** → what will be committed
- **Commit history** → permanent record

Related: [safe commands](recovery.md#safe-commands), [danger zone](recovery.md#danger-zone)

---

## Daily Flow

Related: [safe daily loop](workflow.md#safe-daily-loop), [branching](workflow.md#branching)

git status
git add .
git commit -m "message"

---

## High-Value Tricks

Related: [keeping history readable](workflow.md#keeping-history-readable), [undo last commit but keep changes](recovery.md#undo-last-commit-but-keep-changes)

### See what changed before committing
git diff --staged

### Undo staged file
git restore --staged path/to/file

### Undo file changes
git restore path/to/file

### Amend last commit
git commit --amend

### Quick fix last commit message
git commit --amend -m "new message"

---

## Exploration

Related: [find lost commits](recovery.md#find-lost-commits), [restore a file from history](recovery.md#restore-a-file-from-history)

### Who changed a line?
git blame path/to/file

### Find when something was added/removed
git log -p -S "string"

---

## Cleanup

Related: [clean untracked files safely](recovery.md#clean-untracked-files-safely)

### Remove untracked files
git clean -fd

---

## Recovery Pointers

### Unstage without losing work
[Open recovery note](recovery.md#unstage-without-losing-work)

git restore --staged path/to/file

### Discard local file edits
[Open recovery note](recovery.md#discard-local-file-edits)

git restore path/to/file

### Undo last commit but keep changes
[Open recovery note](recovery.md#undo-last-commit-but-keep-changes)

git reset --soft HEAD~1

### Undo a shared commit safely
[Open recovery note](recovery.md#undo-a-shared-commit-safely)

git revert <commit>

### Find lost commits
[Open recovery note](recovery.md#find-lost-commits)

git reflog

---

## Notes

- Prefer `--oneline --graph --decorate --all` as your default log view
- Always check `git diff --staged` before committing
- Avoid `git reset --hard` unless you really mean it
- Use [recovery notes](recovery.md) when undoing work, especially if commits have been shared
