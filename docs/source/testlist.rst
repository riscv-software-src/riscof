.. _testlist:

################
Test List Format
################

For a given ISA and PLATFORM YAML configuration files, RISCOF is capable of generating a list of
tests that need to be executed on the DUT and Golden model for compliance. This test list can be
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
    test_path: <absolute path of the source of assembly file>

The test-list is meant to be used by the DUT/Golden model plugins to generate execution
environments/Makefile for compliance testing.

A sample test_list.yaml would look like the following:

.. code-block:: yaml

  suite/rv32i_m/C/C-ADD.S:                                                                            
    work_dir: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/rv32i_m/C/C-ADD.S               
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
    test_path: /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscof/suite/rv32i_m/C/C-ADD.S
  suite/rv32i_m/C/C-ADDI.S:                                                                           
    work_dir: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/rv32i_m/C/C-ADDI.S              
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
    test_path: /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscof/suite/rv32i_m/C/C-ADDI.S
  suite/rv32i_m/C/C-ADDI16SP.S:                                                                       
    work_dir: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/rv32i_m/C/C-ADDI16SP.S          
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
  ...
  ...
  ...


