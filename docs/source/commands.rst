.. _commands:

   
###############
RISCOF Commands
###############

This section provides an overview and working of the various sub commands available in RISCOF.
The current list of subcommands includes:

- ``arch-tests``
- ``coverage``
- ``gendb``
- ``setup``
- ``validateyaml``
- ``testlist``
- ``run``

arch-tests
----------
This command is used to clone and update the tests from the official `riscv-arch-test <https://github.com/riscv/riscv-arch-test>`_ repository.

This command requires one of the following flags to be specified from the CLI.

- ``--show-version``: Display the current version of the official suite present at the specified directory path.
- ``--clone``: Clone the suite from github.
- ``--update``: Update the suite to reflect latest changes from github.

Optional arguments from the CLI:

- ``--get-version``: The specific version of the tests to be fetched. Can be used with both the clone and
  update flags. The latest release is fetched if skipped.
- ``--dir``: The path to the directory where the suite is to be cloned to. Defaults to
  ``./riscv-arch-test`` if skipped.

coverage
--------

This command is used to collect the ISA coverage metrics of a given test-suite and generate a coverage
report in html.

This command will require the following inputs from the CLI:

- ``--suite``: The test suite path on which coverage needs to be run.
- ``--env``: The path to the environment directory containing the suite-specific header files.
- ``--cgf``: The list of covergroup-format files specifying the coverpoints that need to be covered by the suite.

Optional arguments from the CLI:

- ``--config``: The path to the ``config.ini`` file. Defaults to ``./config.ini`` if skipped.
- ``--work-dir``: The path to the working directory where all artifacts need to be dumped. Defaults to
  ``./riscof_work``.
- ``--no-browser``: When used, RISCOF skips automatically opening the html report in the default web
  browser.

The coverage command simply passes the cgf files to the reference plugin's runTests function. The
Reference plugin is responsible to generating a YAML based coverage report for each test using ``riscv-isac``. 
The YAML file should be named ``coverage.rpt``. The ``riscv-isac`` run will also generate a data-propagation 
report which should be named as ``ref.md``.

Once the coverage files for each test has been generated, RISCOF will parse through the working
directories and merge all the ``coverage.rpt`` files to create a single YAML coverage report:
``suite_coverage.rpt``. RISCOF then also converts this to an HTML based reports and open it on the
default web-browser.

For a example on using this feature please refer to the :ref:`coverage` section.

gendb
-----

This command is used to generate a database YAML file for all tests available in the test-suite. The
commands requires the following inputs from the CLI:

- ``--suite``: The test suite path for which database needs to be generated.
- ``--work-dir``: The path to the working directory where all artifacts need to be dumped. Defaults to
  ``./riscof_work``.

This utility parses the ``suite`` directory and collects all the .S files. For each .S file, the
utility will parse the test and collect informations from various macros such as RVTEST_ISA,
RVTEST_CASE, etc. For each test the utility will create a new entry in a dictionary which captures
the different parts of the tests, the enabling conditions of each part, the coverage contributions
of each part, any compile macros required for each part and much more.

The generated database YAML will follow the syntax described in section :ref:`database`.

The output of this utility is a ``database.yaml`` located in the ``work_dir`` directory. This file is
used by RISCOF to select and filter tests based on input DUT configuration.

.. note:: The tests that are parsed by the gendb utility must follow the `TestFormat Spec
   <https://github.com/riscv/riscv-arch-test/blob/master/spec/TestFormatSpec.adoc>`_ set forth
   by the riscv-arch-test SIG.

setup
-----

The setup command is used to generate a series of Template files that are required by RISCOF. 
These files are meant to provide ease to users integrating their DUT to RISCOF for the first time
and should be modified by the users.

The setup utility takes in the following optional inputs from the CLI:

- ``--dutname``: The name of the dut for running the tests on. The utility will use this name to create a
  template plugin directory with all the relevant files. These files will have to be modified by 
  the user. Defaults to ``spike`` when skipped.
- ``--refname``: The name of the reference plugin to be used in RISCOF. The utility will use this name to
  create a reference plugin directory with all the relevant files.


The setup utility will also create a sample config.ini file using the above inputs.

validateyaml
------------

This command simply performs a validation of the ISA spec and the platform pspec YAMLs of the DUT
as mentioned in the ``config.ini`` using riscv-config. The outputs are checked for the version of the YAMLs in
the directory pointed to by ``work_dir``.

testlist
--------

This command is used to filter tests from the database.yaml based on the configuration of DUT
present in the ISA and platform YAMLs as mentioned in the ``config.ini``. This command will require 
the following inputs from the CLI:

- ``--suite``: The test suite from which the tests need to be filtered.

This command takes the following optional inputs from CLI

- ``--config``: The path to the ``config.ini`` file. Defaults to ``./config.ini`` if skipped.
- ``--work-dir``: The path to the working directory where all artifacts need to be dumped. Defaults to
  ``./riscof_work``.

The utility first creates a ``database.yaml`` for the input suite. For each test in the database YAML, 
this utility will check if the conditions of any parts of a test are enabled based on the ISA and
platform YAML specs of the DUT. If any part is enabled, then the corresponding test is entered into
the teslist along with the respective coverage labels and compile macros.

The utility will dump the test list in the ``testlist.yaml`` file in the ``work_dir`` directory. This
YAML will follow the same syntax as defined in the :ref:`testlist` section.

run
---

This is probably the primary command of RISCOF which is going to be widely used. This command is
currently responsible for first validating the inputs YAMLs, 
creating a database of the tests in the ``suite`` directory, generate a
filtered test-list, run the tests on the DUT and then the Reference Plugins, and finally compare the
generated signatures and present an html report of the findings.

The following inputs are required on the CLI by this command:

- ``--suite``: The test suite path on which coverage needs to be run
- ``--env``: The path to the environment directory containing the suite-specific header files.

Optional arguments from the CLI:

- ``--config``: The path to the ``config.ini`` file. Defaults to ``./config.ini`` if skipped.
- ``--work-dir``: The path to the working directory where all artifacts need to be dumped. Defaults to
  ``./riscof_work``.
- ``--no-browser``: When used, RISCOF skips automatically opening the html report in the default web browser.
- ``--dbfile``: The path to the database file, from which testlist will be generated.
- ``--testfile``: The path to the testlist file on which tests will be run.
- ``--no-ref-run``: When used, RISCOF will not run tests on Reference and will quit before signatures comparison.
- ``--no-dut-run``: When used, RISCOF will not run tests on DUT and will quit before signatures comparison.
- ``--no-clean``: When used, RISCOF will not remove the ``work_dir``, if it exists. 

The ``work_dir`` is cleaned by default. However, if one of ``no-clean``, ``testfile`` or ``dbfile`` 
are specified, it is preserved as is.

All artifacts of this command are generated in the ``work_dir`` directory. Typical artifacts will
include:

======================== =============================================================
Artifact                 Description
======================== =============================================================
``database.yaml``        This is the database of all the tests in the suite directory.
``Makefile.DUT*``        This is the Makefile generated by the DUT Plugin.
``Makefile.Reference*``  This is the Makefile generated by the Reference Plugin.
``report.html``          The final report generated at the end of the run after signature comparison.
yaml files               Verified and checked YAML versions of the input ISA and platform YAMLs.
``test_list.yaml``       This list of filtered tests from the ``database.yaml``.
src directory            This will include a directory for each test in the ``test_list.yaml``. Each test-directory will include the test, compiled-binaries, signatures from both the DUT and the Reference Plugin.
==================== =============================================================
