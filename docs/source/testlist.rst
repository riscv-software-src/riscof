.. _testlist:

################
Test List Format
################

For a given ISA and PLATFORM YAML configuration files, RISCOF is capable of generating a list of
tests that need to be executed on the DUT and Golden model. This test list can be
generated using the following command:

.. code-block:: bash

  riscof testlist --config=config.ini 

The above command generates a file: ``riscof_work/test_list.yaml``. This file has the following
syntax:

.. code-block:: yaml

  <name of assembly file>:
    work_dir: <absolute path where the file needs to be copied and compiled>
    macros: [ <list of macros that need to be defined during compilation of the test> ]
    isa: <string from the RVTEST_ISA macro from the assembly file>
    coverage_labels: [ <list of covergroups that need to be hit by the test> ]
    test_path: <absolute path of the source of assembly file>

The test-list is meant to be used by the DUT/Golden model plugins to generate execution
environments/Makefile for architectural suite testing.

A sample test_list.yaml would look like the following:

.. code-block:: yaml

  /scratch/git-repo/github/riscv-arch-test/riscv-test-suite/rv64i_m/M/src/div-01.S:
    work_dir: /scratch/git-repo/incoresemi/temp/riscof_work/src/div-01.S
    macros:
    - TEST_CASE_1=True
    - XLEN=64
    isa: RV64IM
    coverage_labels:
    - div
    test_path: /scratch/git-repo/github/riscv-arch-test/riscv-test-suite/rv64i_m/M/src/div-01.S

  /scratch/git-repo/github/riscv-arch-test/riscv-test-suite/rv64i_m/M/src/divu-01.S:
    work_dir: /scratch/git-repo/incoresemi/temp/riscof_work/src/divu-01.S
    macros:
    - TEST_CASE_1=True
    - XLEN=64
    isa: RV64IM
    coverage_labels:
    - divu
    test_path: /scratch/git-repo/github/riscv-arch-test/riscv-test-suite/rv64i_m/M/src/divu-01.S

  /scratch/git-repo/github/riscv-arch-test/riscv-test-suite/rv64i_m/M/src/divuw-01.S:
    work_dir: /scratch/git-repo/incoresemi/temp/riscof_work/src/divuw-01.S
    macros:
    - TEST_CASE_1=True
    - XLEN=64
    isa: RV64IM
    coverage_labels:
    - divuw
    test_path: /scratch/git-repo/github/riscv-arch-test/riscv-test-suite/rv64i_m/M/src/divuw-01.S

  ...
  ...
  ...


