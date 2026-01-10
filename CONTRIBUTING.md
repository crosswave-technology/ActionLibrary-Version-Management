# **Action Library Version Management** | Contributing

| [Home](./README.md)
| [Changelog](./CHANGELOG.md)
| **Contributing**
| [Tech Doc](./techdoc.md)
| <!-- End Of Menu -->

---

Thanks for helping improve this action. This repo is intentionally small, so please keep changes focused and documented.

## Scope

- `action.yaml` defines the composite action.
- `README.md` and `techdoc.md` document behavior and usage.
- `CHANGELOG.md` records user-visible changes.

## Development Workflow

1. Create a feature branch.
2. Make your changes and keep docs in sync with behavior.
3. Update `CHANGELOG.md` under **Unreleased**.
4. Open a PR with a clear description and test notes.

## Testing

Use a scratch repo with a `VERSION` file:

- Root mode: put `VERSION` at repo root and run the workflow on a PR with a label like `Patch`.
- Per-feature mode: remove the root `VERSION`, add `feature_x/VERSION`, modify files under `feature_x/`, and run with `pr_number`.
- Confirm the action commits and pushes the updated version file(s).

## Style Guidelines

- Keep docs in Markdown and ASCII only.
- Use simple, explicit error messages.
- Keep YAML indentation at two spaces.

## PR Checklist

- Docs match behavior (`README.md`, `techdoc.md`).
- `CHANGELOG.md` updated.
- Test notes included in the PR description.

---

<p style="text-align: center;"><a href="#">Return to Top</a></p>

<h6 style="text-align: center;">Copyright &copy; Crosswave Technology Ltd</h6>
