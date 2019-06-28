# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Enabling external plugin support.
- Report Generation.
- RiscV OVPsim support. 

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