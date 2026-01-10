# **Action Library Version Management**

| **Home**
| [Changelog](./CHANGELOG.md)
| [Contributing](./CONTRIBUTING.md)
| [Tech Doc](./techdoc.md)
| <!-- End Of Menu -->

---

Promotes VERSION file(s) based on PR labels or commit messages. Designed for repos that keep a single root VERSION or per-feature VERSION files.

## Overview

This composite action bumps semantic versions and commits the updated VERSION file(s) back to the repo. It determines the bump type from PR labels, PR title, or commit message markers.

## Behavior Summary

- Default target: `./VERSION` if it exists.
- Optional target: `version_file` input (relative to repo root) when provided.
- Fallback: discover VERSION files by walking parent directories of PR-changed files and collecting all VERSION files found.
- Applies one promotion type to all discovered VERSION files.
- Commits and pushes changes using `github-actions[bot]`.

## Inputs

| Name | Required | Description |
| --- | --- | --- |
| `pr_number` | No | PR number used for label lookup and file discovery. |
| `version_file` | No | Preferred VERSION file path (relative to repo root). If missing or not found, discovery is used. |

## Permissions

- `contents: write` to commit and push the updated file(s).
- `pull-requests: read` to read labels and PR file lists.

## Requirements

- The repo must be checked out before running the action.
- `gh` CLI and `git` are required (present on GitHub-hosted runners).
- `GITHUB_TOKEN` or `GH_TOKEN` must be available.

## Usage

### Pull Request Event (Root VERSION)

```yaml
on:
  pull_request:
jobs:
  promote:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: read
    steps:
      - uses: actions/checkout@v4
      - uses: crosswave-technology/ActionLibrary-Version-Management@main
        with:
          pr_number: ${{ github.event.pull_request.number }}
```

### Push Event (After Merge)

```yaml
- name: Discover PR
  id: lookup
  uses: actions/github-script@v6
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      const { data: prs } = await github.rest.repos.listPullRequestsAssociatedWithCommit({
        owner: context.repo.owner,
        repo: context.repo.repo,
        commit_sha: context.sha
      });
      if (prs.length === 0) core.setFailed("No PR found");
      else core.setOutput("pr_number", prs[0].number);

- name: Promote version
  uses: crosswave-technology/ActionLibrary-Version-Management@main
  with:
    pr_number: ${{ steps.lookup.outputs.pr_number }}
```

### Per-Feature VERSION File

```yaml
- uses: actions/checkout@v4
- uses: crosswave-technology/ActionLibrary-Version-Management@main
  with:
    version_file: feature_1/VERSION
    pr_number: ${{ github.event.pull_request.number }}
```

## Version File Format

The file must contain a single semantic version string:

```text
1.2.3
```

Whitespace is trimmed.

## Promotion Markers

The action looks for the following markers (case-insensitive):

- Labels: `Major`, `Minor`, `Patch`
- PR title: same strings
- Commit message (fallback): same strings

The `Documentation` label is ignored by this action.

If none are found, the action fails.

## Discovery Rules

Order of precedence:

1. `version_file` input if provided and exists.
2. Root `./VERSION` if present.
3. If `pr_number` is provided, walk parent directories of each changed file and collect all `VERSION` files found (de-duplicated).
4. Fail if nothing is found.

Note: If a root `VERSION` exists, per-feature discovery is skipped.

## Troubleshooting

- `No valid promotion type found`: ensure the PR has one of the required labels or markers.
- `No VERSION files found`: add `VERSION` at repo root or ensure PR-changed directories contain `VERSION`.
- `Invalid version format`: ensure the file contains `X.Y.Z` only.
- `Push failed`: confirm `contents: write` and that the workflow runs on a branch the token can push to.

---

<p style="text-align: center;"><a href="#">Return to Top</a></p>

<h6 style="text-align: center;">Copyright &copy; Crosswave Technology Ltd</h6>
