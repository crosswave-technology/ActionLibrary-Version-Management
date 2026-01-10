# **Action Library Version Management** | Changelog

| [Home](./README.md)
| **Changelog**
| [Contributing](./CONTRIBUTING.md)
| [Tech Doc](./techdoc.md)
| <!-- End Of Menu -->

---

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project aims to follow SemVer.

## [Unreleased]

### Added

- `version_file` input to target a specific VERSION file when present.
- PR-based discovery of per-feature VERSION files when no root VERSION exists.
- Expanded usage and troubleshooting documentation.

### Changed

- Action now updates VERSION file(s) and commits to the repo instead of updating a GitHub variable.
- Promotion markers now use `Major`, `Minor`, and `Patch` labels (case-insensitive).
- PR discovery now collects all VERSION files along changed file paths (de-duplicated).
- VERSION values now support an optional leading `v` (preserved on write).

---

<p style="text-align: center;"><a href="#">Return to Top</a></p>

<h6 style="text-align: center;">Copyright &copy; Crosswave Technology Ltd</h6>
