# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Spec Coverage
- Clean up of macros to ensure bare minimum and necessary code for testing.
- Privilege tests for machine csrs.

## [1.5.2] - 2019-07-10
### Fixed
- Errors in macro documentation.

### Changed
- Changed macro name prefixes to RVTEST and RVMODEL based on their definitions and functions.

## [1.5.1] - 2019-07-09
### Added
- Html Report Generation.
- Supervisor csrs to schema.
- Documentation update for Supervisor csrs.

### Changed
- Use difflib instead of filecmp for signature comparision.

### Fixed
- Bug fix for mstatus(it is to be treated as a required field).

## [1.5.0] - 2019-07-02
### Added
- External plugin support.

### Changed
- pluginTemplate is now implemented as an ABC.
- Documentation update.

### Removed
- No plugins included in the default package.

## [1.4.1] - 2019-06-28
### Added
- requirements.txt file in docs for sphinx build

### Fixed
- setup.py modified for pypi installation
- README.rst

### Removed
- README.md as this is replaced with README.rst.

## [1.4.0] - 2019-06-27
### Added
- Setup script for PyPI integration.
- A single entry point integrating framework and rips.
- Support for system wide install of the package.
- "Command" class to ensure future extensibility and cross-platform compatibility.
- Support for "RVTEST_SIG*" macros.

### Changed
- Directory structure to encapsulate all modules into one shippable package.
- Ensured python coding practices are followed.
- Modified I and M test suites to confirm to the latest test specifications.

### Removed
- Relative and wildcard imports and stray obsolete portions of code and files.
