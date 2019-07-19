# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Parallelizing Execution on models
- Privilege tests for machine csrs.
- Spec Coverage

## [1.7.2] - 2019-07-19
### Fixed
- ci-cd for pdf hosting on gitlab itself

## [1.7.1] - 2019-07-19
### Fixed
- Removed stray text in flow diagram.
- docs for pdf generation.

## [1.7.1] - 2019-07-19
### Fixed
- Removed stray text in flow diagram.
- docs for pdf generation.

## [1.7.0] - 2019-07-19
### Changed
- Uses *rifle* instead of *rips* subpackage.
### Removed
- *rips* module is no longer a subpackage.
- Examples folder removed from the repository.

## [1.6.3] - 2019-07-17
### Fixed
- Fixed setup.py for pypi compatibility.

## [1.6.2] - 2019-07-17
### Added
- MANIFEST.in file added.

### Changed
- `setup.py` modified to add suite properly.
- Package requirements updated appropriately.
- gitlab-cicd to use version-extract.py for generating tags.

### Fixed
- Errors in quickstart documentation.

## [1.6.1] - 2019-07-15
### Added
- Links to yaml specifications in the report.
- Background to the flow picture.
- WIP indication in docs for user features.

## [1.6.0] - 2019-07-12
### Added
- `--setup` option to generate setup files in *pwd*.
- Added support for separate environment files for model and standard macros.
- New model specific macros.

### Changed
- Configuration for riscof is taken through `config.ini` file in the *pwd*.
- Suite directory structure to follow the standard.
- Moved `C` and `A` extension tests to *wip* folder.
- Modified macros into new `RVTEST_` and `RVMODEL_` prefixed macros.
- Macro list for compile now passed as a list instead of `-D` prefixed string.

### Removed
- Clean up of macro definitions to ensure bare minimum and necessary code for testing.


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
