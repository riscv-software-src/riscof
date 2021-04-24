.. _newtest:

################
Adding New Tests
################

This section pertains to developers who wish to add new tests to the architectural test suite. 
Please follow the below steps for such contributions:

1. All tests should strictly follow the test-spec format available here: 
   :ref:`Test Spec Format<test_format_spec>`

2. The test should then be placed in the appropriate folder within the ``riscof/riscof/suite``
   directory. Guidelines on directory structure are also available in the same
   Test Spec Format mentioned above.

3. After adding the test in the suite directory, you will have to generate the
   database YAML using the following command:

   .. code-block:: bash
   
     riscof gendb

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
