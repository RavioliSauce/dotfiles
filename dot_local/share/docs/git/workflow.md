# Git Workflow Notes

This page is a linked sibling Markdown file for testing Grip navigation.

Start from the [Git cheatsheet](cheatsheet.md), jump directly to its
[daily flow section](cheatsheet.md#daily-flow), or open the
[recovery notes](recovery.md) when undoing work.

## Safe Daily Loop

Use this loop when changing a repository:

1. Inspect the current state.
2. Make a small, focused change.
3. Review unstaged changes.
4. Stage only the intended files.
5. Review staged changes.
6. Commit with a specific message.

```bash
git status
git diff
git add path/to/file
git diff --staged
git commit -m "Describe the focused change"
```

Related: [daily flow commands](cheatsheet.md#daily-flow), [safe commands](recovery.md#safe-commands).

## Branching

Create a branch when the work may take more than one commit, touches risky
code, or needs review before landing.

```bash
git switch -c fix/clear-description
git status
```

To move between existing branches:

```bash
git switch main
git switch fix/clear-description
```

## Reviewing Before Commit

Prefer reviewing the exact staged patch before every commit:

```bash
git diff --staged
```

If a file was staged by mistake:

```bash
git restore --staged path/to/file
```

Related: [diffing changes](cheatsheet.md#diffing-changes), [unstage without losing work](recovery.md#unstage-without-losing-work).

## Keeping History Readable

Good commits are small, named clearly, and contain one logical change. If the
last commit message is unclear, amend it before sharing:

```bash
git commit --amend -m "Use clearer commit message"
```

Avoid rewriting commits that other people may already have based work on.

Related: [fix last commit](recovery.md#fix-last-commit), [undo a shared commit safely](recovery.md#undo-a-shared-commit-safely).

## More References

- Back to the [main cheatsheet](cheatsheet.md).
- Open the [recovery notes](recovery.md).
- Review [diffing commands](cheatsheet.md#diffing-changes).
- Review [cleanup commands](cheatsheet.md#cleanup).
