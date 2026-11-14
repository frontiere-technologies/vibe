---
name: vibe-update
description: Bring a project started from the vibe template up to a later template version, recorded in .vibe-template, with a three-way merge that keeps the project's own changes. Use when the user says "update the template", "pull the template changes", "upgrade vibe" or asks which template version the project is on.
---

Update the project to a later version of the vibe template. `.vibe-template` says where the template lives (`repository`), which version the project came from (`version`), which paths the template owns (`owned`: merged three-way) and which it only suggests (`advisory`: applied only on the developer's yes). *Keeping the environment up to date* in `vibe/README.md` explains why; `vibe/CHANGELOG.md` says what each version changes.

The rule above all others: never overwrite a project's own change without showing it first. A conflict is left in the file for the developer, not resolved by picking a side.

Run the commands from the repository root with bash. Each one stands alone: write the values read in step 1 in place of `<repository>`, `<old>` and `<new>`. Working files go in `$(git rev-parse --git-path vibe-update)`, which is inside `.git` and never committed.

## 1. Start

1. If `.vibe-template` is missing, stop: the project predates it, and `vibe/CHANGELOG.md` (0.1.0, *By hand*) says how to create it.
2. `git status --porcelain` must print nothing. Otherwise stop and ask the developer to commit or set the changes aside first: the update must be the only change in the tree, so that it can be shown and undone.
3. Read `repository` and `version` (= `<old>`) from `.vibe-template`. The target `<new>` is the version the developer names, or else the highest release tag:

   ```bash
   git ls-remote --tags <repository> 'v*' | sed -n 's|.*refs/tags/v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)$|\1|p' | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1
   ```

   If `<new>` is `<old>` or lower, say the project is up to date and stop.
4. Follow *Git workflow* in `AGENTS.md` for where the change goes (by default a new branch, `git switch -c vibe-update-<new>`).

## 2. Fetch and prepare

```bash
git fetch --no-tags <repository> "+refs/tags/v<old>:refs/vibe/old" "+refs/tags/v<new>:refs/vibe/new"
```

If the lists in `git show refs/vibe/new:.vibe-template` differ from the project's, show the difference: the project's lists apply, unless the developer edits them now.

Then turn the two lists into git pathspecs. The entries are globs (`wiki-*/`), so they get the `:(glob)` magic, and a folder entry ends in `**` (in glob magic a bare `wiki-*/` matches nothing). The pathspecs are written one per line and passed to git with `xargs`, so the shell never expands the globs:

```bash
d=$(git rev-parse --git-path vibe-update); mkdir -p "$d"
for l in owned advisory; do awk -v l="$l" '$0 ~ "^" l ":" {in_l=1; next} /^[^ ]/ {in_l=0} in_l && $1 == "-" {p=$2; if (p ~ /\/$/) p = p "**"; print ":(glob)" p}' .vibe-template > "$d/$l"; done
```

Paths the project deleted on purpose (typically `vibe/tutorial/`, or `.agents/agents/ui-ux-tester.md`) must not come back. List the files present at `<old>` and absent now, reduced to the topmost missing folder:

```bash
d=$(git rev-parse --git-path vibe-update)
cat "$d/owned" "$d/advisory" | xargs git diff --no-renames --name-only --diff-filter=D refs/vibe/old HEAD -- | while IFS= read -r f; do top=$f; p=$(dirname "$f"); while [ "$p" != . ] && [ ! -e "$p" ]; do top=$p/; p=$(dirname "$p"); done; echo "$top"; done | sort -u > "$d/deleted"
sed 's|^|:(exclude)|' "$d/deleted" > "$d/exclude"; cat "$d/deleted"
```

Tell the developer these paths stay out, and for each one whether the template changed it (`git diff --stat refs/vibe/old refs/vibe/new -- <path>`). A path the developer wants back is restored as it is at `<new>` with `git checkout refs/vibe/new -- <path>`, and its line is removed from `$d/exclude`. Files the template added between the two versions are not in this list: they arrive with the merge, unless they sit in an excluded folder.

## 3. Owned paths: three-way merge

Show first, then apply:

```bash
d=$(git rev-parse --git-path vibe-update)
cat "$d/owned" "$d/exclude" | xargs git diff --stat refs/vibe/old HEAD --            # the project's own changes
cat "$d/owned" "$d/exclude" | xargs git diff --stat refs/vibe/old refs/vibe/new --   # the template's changes
cat "$d/owned" "$d/exclude" | xargs git diff --binary refs/vibe/old refs/vibe/new -- | git apply -3
```

Skip the last line when the template's `--stat` is empty (`git apply` rejects an empty patch). `git apply -3` stages what merges cleanly and leaves conflict markers where both sides changed the same lines. List the conflicts with `git diff --name-only --diff-filter=U`; if there are any, show each one and stop. The developer resolves them (and runs `git add` on each); the update goes on only when they say so.

If `git apply` prints `error: <file>: patch does not apply` instead, it applied nothing: typically the template deletes a file the project changed. Show the project's change (`git diff refs/vibe/old HEAD -- <file>`) and ask: delete the file as the template does (`git rm <file>`), or keep it. Either way add `:(exclude)<file>` to `$d/exclude` and run the last line again.

## 4. Advisory paths: one at a time, only on yes

For each line of `$d/advisory`, show the template's diff:

```bash
d=$(git rev-parse --git-path vibe-update)
{ echo '<pathspec>'; cat "$d/exclude"; } | xargs git diff refs/vibe/old refs/vibe/new --
```

Nothing to show: go to the next. Otherwise ask whether to apply it, and wait. On yes, run the same command with `--binary` and pipe it to `git apply -3`; a conflict is shown and left for the developer, as in step 3. On no, change nothing and note it for the commit message.

## 5. Changelog and version

1. Show what changed in between, from the top of the new changelog to the heading of `<old>`:

   ```bash
   git show refs/vibe/new:vibe/CHANGELOG.md | awk -v h="## <old> " 'index($0, h) == 1 {exit} {print}'
   ```

   Go through the *By hand* items with the developer; do each only on their yes.
2. Set the version, and only that line: `sed 's/^version: .*/version: <new>/' .vibe-template > .vibe-template.new && mv .vibe-template.new .vibe-template`.
3. Run `bash vibe/scripts/check-setup.sh` and report every `FAIL` line.

## 6. Finish

- Show `git status` and `git diff HEAD --stat`, then ask before committing. On yes: `git add -A`, then a commit with subject `Update the vibe template from <old> to <new>` and a body that lists the excluded paths and the advisory paths not applied.
- To abandon the update instead, `git reset --hard HEAD` brings the tree back to where step 1 left it (the tree was clean); it discards any conflict resolution, so it runs only on the developer's yes. Then switch back to the branch the update started from, and delete the update branch if step 1 made one.
- Either way, clean up: `git update-ref -d refs/vibe/old; git update-ref -d refs/vibe/new; rm -rf "$(git rev-parse --git-path vibe-update)"`.
- Never push, and never create a tag, remote or issue.
