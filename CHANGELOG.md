# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.19.0] - 2021-04-24
- Added new rv64i and rv32i tests from arch-test repo
- Added K_unratified tests from arch-test repo
- Addded all relevant coverage files 
- Updated coverage support to pick local coverage files
- Updated setup phase to dump out sail_cSim reference model
- Updated the config.ini and model setup files
- Updated docs

## [1.18.4] - 2021-01-27
- Fixed missing coverage.html during pip installation.

## [1.18.3] - 2021-01-21
- Added support for paths relative to `config.ini` location
- Plugins get the location of `config.ini` directory with the key `config_dir`

## [1.18.2] - 2021-01-14
- Fixed missing files in PYPI package
- Added `physical_addr_sz` field in model_isa.yaml

## [1.18.1] - 2021-01-11
- updated ci to use latest twine
- using api-tokens for twine uploads

## [1.18.0] - 2021-01-11
- updated cli to accept multiple cgf files similar to isac
- doc updates with fixes to broken links
- manifest fixed to include requirements file

## [1.17.2] - 2020-11-10
- doc updates
- added contributing.rst file
- changed version maintenance procedure. Using bumpversion now.

## [1.17.1] - 2020-10-26
- doc fix
- fix passing of cgf from command line to internal variable

## [1.17.0] - 2020-10-26
- Adding coverage support using riscv-isac=0.3.0
- Adding default CGF file in the suite folder
- Re structured tests to be compatible with test-format spec and for coverage analysis
- Updated docs and test-format spec

## [1.16.2] - 2020-08-05
- Removed coverage support and cgf file(will be reintroduced when riscv-isac is released).
- Freeze riscv-config to v2.2.2

## [1.16.1] - 2020-07-20
- Adding docs for rvtest_case condition string syntax.

## [1.16.0] - 2020-06-18
- Adding coverage generation support through spike --log-commits
- CGF file for rv32i for now.
- Also added pipecleaning tests under wip

## [1.15.2] - 2020-05-18
- changed python vrsion to be 3.6 or above. This makes installation of python easy
- update docs with more details on installation and fixed other typos as well.

## [1.15.1] - 2020-04-07
### Added
- doc updates for test-format structure
### Changed
- RVMODEL_BOOT is no longer subsumed within the RVTEST_COMPLIANCE_BEGIN macro


## [1.15.0] - 2020-03-29
### Added
- Supports riscv-config version > 2.0
- Added Test-format spec to the docs
- adding ci for checks on each pull-request. 
### Fixed
- Fixed hyperlink to test-format-spec in new-test sections

## [1.14.1] - 2020-03-25
### Changed
- Changed the command line args to use subparsers and added relevant documentation.


## [1.14.0] - 2020-03-21
### Fixed 
- Migrated C-extension tests to those available on github. This required adding and fixing special
  macros
- C.SWSP test has been fixed to not access regions outside the signature region
- Moved ECALL, EBREAK and MIS-ALIGNED tests to a separate folder. Also their respective TEST_CASE
  conditions have been updated
- Moved Atomic tests to wip folder.
- renamed I-IO.S to I-IO-01.S

## [1.13.4] - 2020-03-18
### Fixed 
- load_yaml function in utils forced to return dict type.

## [1.13.3] - 2020-03-18
### Fixed 
- moved requirements.txt inside riscof

## [1.13.2] - 2020-03-17
### Fixed 
- Removed duplicate env folder.
- Fixed exclusion of env folder in pip package.
- Reduced python package dependencies

## [1.13.1] - 2020-02-26
### Fixed
- shipping the model folder as well
## [1.13.0] - 2020-02-26
### Fixed
- PyPi is now shipped with compressed and atomic tests
- docs have been updated with developer related information
- Shifted to the new test-suite available on github
### Added
- Update docs for : install, macros and usage example
- Setup command has been updated to create sample plugin folder with all collaterals required for
  running RISCOF.
- Added version argument support
- Version is also printed at the begining of each run

## [1.12.0] - 2020-02-10
### Fixed
- RISCOF now checks if the sign dumps are not empty before comparing them.
- Print help when no arguments specified in command line.
### Added
- A Makefile generation utility to avoid plugins re-writing it always.
- Automated adding paths to PYTHONPATH.
- Support for custom suites.

## [1.11.1] - 2019-11-28
### Added
- Update docs for : install, macros and usage example.

## [1.11.0] - 2019-10-23
### Added
- Added support to generate test list only through command line.
- Added support to generate test generate validated YAML files only through command line.
### Fixed
- Fixed path to riscv-config yaml-specs in html report.
- Fixed error in documentation.

## [1.10.0] - 2019-08-12
### Added
- Ported A extension tests to latest spec.
### Fixed
- Fixed logging issue with riscv-config v1.0.2.
- Fixed undefined macro in M extension tests.

## [1.9.0] - 2019-08-07
### Added
- Ported C extension tests to latest spec.

## [1.8.2] - 2019-08-02
### Fixed
- minor doc updates to replace rifle with riscv-config 

## [1.8.1] - 2019-08-02
### Changed
- Changed dependency from rifle to riscv-config.

## [1.8.0] - 2019-08-02
### Changed
- Parallel Execution on models.
- Signature files are mandated to be self.name[:-1]+".signature"

## [1.7.4] - 2019-07-23
### Changed
- Patch to support rifle version 1.1.0

## [1.7.3] - 2019-07-19
### Changed
- bumping rifle to 1.0.3

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
