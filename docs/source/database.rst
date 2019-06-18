.. _database:

Database Generator
^^^^^^^^^^^^^^^^^^^^^

This module recursively walks the specified directory(/suite/modified) to find all .S files in them and constructs a database for the framework.

The nodes in the directory are identified by their relative path from the repository home.
Each node in the database is defined as follows:

* file path:
    * commit_id: Contains the recent commit id of the commit in which the test was modified.
    * isa: Contains the isa required for the compilation of the test. This field is extracted from the *RVTEST_ISA* macro.
    * parts: Contains the individual parts present in the test and the conditions and macros required by each of them. The parts are identified by unique names as specified in the test. A test must contain atleast one part for it to be included in the database.
        * part name: This node is extracted from the *RVTEST_CASE_START* macro in the test.
            * check: A list of the check statements for the part as specified in the test. These translate to the conditions which need to be satisfied for this part to be included.
            * define: A list of define statements for the part as specified in the test. These translate to the macros required by this part to run.
            * coverage: Contains the coverage of the test part.*

\* - To be implemented

Example:

.. code-block:: yaml

    /suite/modified/C-ADD.S:
        isa: RV32IC
        commit_id: a3ce9d44d0480b3a13e47a079291518e9633d2fa
        parts:
            '1':
                check:
                    - check ISA:=regex(.*I.*)
                    - check ISA:=regex(.*C.*)
                define:
                    - def TEST_PART_1=True
                coverage: RV32IC

Usage:

.. code-block:: bash

    python3 -m dbgen.main