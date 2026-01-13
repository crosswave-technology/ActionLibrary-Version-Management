# **Action Library Version Management** | Tech Doc

| [Home](./README.md)
| [Changelog](./CHANGELOG.md)
| [Contributing](./CONTRIBUTING.md)
| **Tech Doc**
| <!-- End Of Menu -->

---

## Purpose

Provide a lightweight, repo-local way to promote semantic version numbers by updating VERSION file(s). The action reads labels or commit/title markers to determine the bump type, writes the new version, and commits the change.

## Inputs

- `pr_number` (optional): PR number used to read labels and the list of changed files.
- `version_file` (optional): preferred VERSION file path relative to repo root.

## Execution Flow

1. Authenticate GitHub CLI using `GH_TOKEN` or `GITHUB_TOKEN`.
2. Determine the promotion type (`major`, `minor`, `patch`) using:
   - PR labels: `Major`, `Minor`, `Patch` (case-insensitive; `Documentation` is ignored)
   - PR title (fallback)
   - Commit message (final fallback)
3. Resolve VERSION file targets:
   - Use `version_file` if provided and it exists.
   - Else use `./VERSION` if it exists.
   - Else discover VERSION files from PR-changed paths.
4. For each VERSION file:
   - Read and validate `X.Y.Z`.
   - Compute new version based on promotion type.
   - Write the new version back to the file.
5. If any changes exist, commit and push using `github-actions[bot]`.

## Discovery Algorithm

When `version_file` is not provided and root `VERSION` is missing:

1. Use the PR file list via `gh api repos/.../pulls/{pr_number}/files`.
2. For each changed file:
   - Start at the file directory.
   - Walk up the parent directories until repo root.
   - Collect all `VERSION` files found along the path.
3. De-duplicate VERSION paths and update each once.

If no VERSION files are found, the action fails.

## Promotion Algorithm

Leading `v` is allowed and preserved. Given current version `X.Y.Z`:

- `major`: `X+1.0.0`
- `minor`: `X.(Y+1).0`
- `patch`: `X.Y.(Z+1)`

All targeted VERSION files receive the same promotion type.

## Git Operations

- Uses `git diff --quiet` to detect changes.
- Commits with message `ci: promote version (old -> new)` and lists updated files in the body for multi-file updates.
- Pushes to the current branch with `git push`.

## Permissions and Tokens

- Requires `contents: write` to push changes.
- Requires `pull-requests: read` to read labels and PR file lists.
- Uses `GITHUB_TOKEN` or `GH_TOKEN` for `gh` authentication.

## Failure Modes

- No promotion marker found (labels/title/commit message).
- VERSION file not found or not discoverable.
- VERSION file contains an invalid format (non `X.Y.Z`).
- Push fails due to insufficient permissions or branch protection.

## Operational Considerations

- If a root `VERSION` file exists, per-feature discovery is skipped.
- VERSION-only commits can re-trigger workflows; use path filters or guard logic if needed.
- Parallel runs can conflict; consider workflow concurrency controls on the target branch.

## Repo Layout Guidance

If you use per-feature versions, place `VERSION` in each feature directory and ensure changes touch those directories so discovery can find them. For explicit control, pass `version_file`.

---

<p style="text-align: center;"><a href="#">Return to Top</a></p>

<h6 style="text-align: center;">Copyright &copy; Crosswave Technology Ltd</h6>
