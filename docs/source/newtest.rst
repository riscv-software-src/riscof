.. _newtest:

######################
Adding New Tests [Dev]
######################

This section pertains to developers who wish to add new tests to the compliance
suite. Please follow the below steps for such contributions:

1. All tests should strictly follow the test-spec format available here: 
   `Test Spec Format <https://github.com/allenjbaum/riscv-compliance/blob/master/spec/TestFormatSpec.pdf>`_

2. The test should then be placed in the appropriate folder within the ``riscof/riscof/suite``
   directory. Guidelines on directory structure are also available in the same
   Test Spec Format mentioned above.

3. After adding the test in the suite directory, you will have to generate the
   database YAML using the following command:

   .. code-block:: bash
   
     python -m dbgen.main

   The above command will generate a new file: ``framework/database.yaml``
   For more information on the dbgen utility please refer: :ref:`database`

4. Please update the CHANGELOG.md file with your changes.
5. You can now create a merge request on the RISCOF repository which should
   contain the following:

    - updated CHANGELOG.md file
    - updated database.yaml file
    - new assembly file in the suite-directory

The maintainer is now responsible for reviewing the changes and update the
version number in ``riscof/__init__.py`` for proper pypi deployment.
