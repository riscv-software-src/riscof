.. _database:

##################
Database Generator
##################

RISCOF includes an internal utility which is used to generate a database of all the assembly tests
available in a ``suite`` directory. This database is maintained as a YAML file and serves the 
purpose of selecting relevant tests for a given DUT model. 

The ``dbgen`` utility recursively walks the specified ``suite`` to find all .S files 
in them and constructs a dictionary of sorts, for the framework.
The tests in the directory are identified by their relative path from the repository home.
Each test in the database is defined as follows:

* **file path**: the absolute path of the test on the said system:

    * ``commit_id``: Contains the recent commit id of the commit in which the test was modified.

    * ``isa``: Contains the ISA required for the compilation of the test. This field is extracted from the ``RVTEST_ISA`` macro.

    * ``parts``: Contains the individual parts present in the test and the conditions and macros required by each of them. The parts are identified by unique names as specified in the test. A test must contain at-least one part for it to be included in the database.

        * **part name**: This node is extracted from the ``RVTEST_CASE_START`` macro in the test.

            * ``check``: A list of the check statements for the part as specified in the test. These translate to the conditions which need to be satisfied for this part to be included.
            * ``define``: A list of define statements for the part as specified in the test. These translate to the macros required by this part to run.

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

Usage
^^^^^

.. code-block:: bash

    riscof --verbose debug gendb --env /path/to/env/ --suite /path/to/suite/

Reasons of Failure
^^^^^^^^^^^^^^^^^^

Possible scenarios where database is not generated:

  * There does not exist at-least one part in the test.
  * Any part which has started does not end before another part starts or the code ends i.e. ``RVTEST_CASE_START`` exists for that part but ``RVTEST_CASE_END`` doesn't.
  * The part names given in a ``RVTEST_CASE_START``-``RVTEST_CASE_END`` pair doesn't match.
  * ``RVTEST_ISA`` macro isn't present in the test.

Notes
^^^^^

1. The database is always alphabetically ordered.
2. The database checks for macro sanity - i.e. certain macros exists and in the correct order.
3. Each time a new test is added to the ``suite`` directory, the database utility has to be run manually and the ``database.yaml``
   has to be up-streamed manually to the repository.

