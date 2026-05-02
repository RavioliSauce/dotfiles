# Git Recovery Notes

Start from the [Git cheatsheet](cheatsheet.md), or jump back to its
[recovery pointers](cheatsheet.md#recovery-pointers).

Use this page when you want to undo something without guessing at destructive
commands.

## First Rule

Before undoing anything, inspect what Git thinks is true:

```bash
git status
git diff
git diff --staged
```

If commits are involved, inspect the recent history:

```bash
git log --oneline --graph --decorate --all -n 20
```

## Safe Commands

These commands are usually safe because they either inspect state or preserve
your work:

```bash
git status
git diff
git diff --staged
git restore --staged path/to/file
git stash push -m "message"
git revert <commit>
```

## Unstage Without Losing Work

Use this when you added a file too early:

```bash
git restore --staged path/to/file
```

Then review what remains unstaged:

```bash
git diff
```

Related: [diffing changes](cheatsheet.md#diffing-changes), [reviewing before commit](workflow.md#reviewing-before-commit).

## Discard Local File Edits

Use this only when you do not want the current edits in a file:

```bash
git restore path/to/file
```

For all unstaged tracked-file edits:

```bash
git restore .
```

Check first with:

```bash
git diff
```

## Restore A File From History

Restore a file from the latest commit:

```bash
git restore path/to/file
```

Restore a file from a specific commit or branch:

```bash
git restore --source <commit> -- path/to/file
git restore --source main -- path/to/file
```

Inspect the old file before restoring:

```bash
git show <commit>:path/to/file
```

Related: [inspecting commits](cheatsheet.md#inspecting-commits).

## Undo Last Commit But Keep Changes

Use this when the last commit should be redone, but the file changes are still
wanted:

```bash
git reset --soft HEAD~1
```

The changes remain staged. If you want them unstaged:

```bash
git restore --staged .
```

Avoid this after pushing if someone else may have based work on that commit.

## Fix Last Commit

Use this when the last commit is basically right but needs a small correction:

```bash
git add path/to/file
git commit --amend
```

Fix only the message:

```bash
git commit --amend -m "Better message"
```

Related: [keeping history readable](workflow.md#keeping-history-readable).

## Undo A Shared Commit Safely

Use `revert` for commits that may already be pushed or shared:

```bash
git revert <commit>
```

This creates a new commit that reverses the old one instead of rewriting
history.

To revert the latest commit:

```bash
git revert HEAD
```

## Find Lost Commits

Use reflog when a branch moved and you need to find where it used to point:

```bash
git reflog
```

Inspect a candidate:

```bash
git show <reflog-entry>
```

Create a rescue branch before experimenting:

```bash
git switch -c rescue <reflog-entry>
```

Related: [exploration commands](cheatsheet.md#exploration).

## Stash Work Temporarily

Stash tracked-file changes:

```bash
git stash push -m "describe the pause"
```

Include untracked files:

```bash
git stash push -u -m "describe the pause"
```

List stashes:

```bash
git stash list
```

Apply the latest stash and keep it in the stash list:

```bash
git stash apply
```

Apply and remove the latest stash:

```bash
git stash pop
```

## Clean Untracked Files Safely

Preview what would be removed:

```bash
git clean -fdn
```

Remove untracked files and directories:

```bash
git clean -fd
```

Remove ignored files too:

```bash
git clean -fdx
```

Use `-n` first when unsure.

Related: [cleanup commands](cheatsheet.md#cleanup).

## Danger Zone

These commands can destroy local work or rewrite history:

```bash
git reset --hard
git clean -fdx
git push --force
```

Prefer safer alternatives first:

- Use `git restore --staged` to unstage.
- Use `git revert` to undo shared commits.
- Use `git clean -fdn` before deleting untracked files.
- Create a rescue branch from `git reflog` before experimenting.

## More References

- Back to the [main cheatsheet](cheatsheet.md).
- Review the [safe daily loop](workflow.md#safe-daily-loop).
- Review [high-value tricks](cheatsheet.md#high-value-tricks).
