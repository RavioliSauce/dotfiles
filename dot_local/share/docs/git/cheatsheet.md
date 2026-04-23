# Git Cheatsheet (Practical)

Related: [Git workflow notes](workflow.md)

## Inspecting History

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

---

## Daily Flow

git status
git add .
git commit -m "message"

---

## High-Value Tricks

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

### Who changed a line?
git blame path/to/file

### Find when something was added/removed
git log -p -S "string"

---

## Cleanup

### Remove untracked files
git clean -fd

---

## Notes

- Prefer `--oneline --graph --decorate --all` as your default log view
- Always check `git diff --staged` before committing
- Avoid `git reset --hard` unless you really mean it
