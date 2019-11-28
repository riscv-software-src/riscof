.. _test_macros:

##################
Macro Descriptions
##################

Standard Test Macros
--------------------

These are the list of standard macros which can be used by a test-developer. These are not to be
modified and to be used as is defined. The definitions for the macros can be found `here. <https://gitlab.com/incoresemi/riscof/blob/master/riscof/suite/env/compliance_test.h>`_

**RVTEST_ISA(_STR)**

* Arguments: 
  
    * _STR: ISA confirming to the latest RISCV ISA specification

* Description:

    Empty macro to specify the isa required for compilation of the test. This is the first macro which the dbgen (database-generator) module looks for and is mandated to be present at the start of the test.

* Usage:

.. code-block:: c

    RVTEST_ISA("RV32IC")

**RVTEST_CODE_BEGIN**

* Arguments: None

* Description:

    Macro to indicate the start of the code block in the test and add the startup routine for the test. 
    No part of the code section should precede this macro. 

**RVTEST_CODE_END**

* Arguments: None

* Description:

    Macro to indicate the end of the code block in the test.No part of the code section should follow after this macro.

**RVTEST_CASE( _PNAME, _DSTR )**

* Arguments:

    * _PNAME: The name of the part. Can be any aplhanumeric string.

    * _DSTR: The conditions which decide whether this particular test-case is enabled. One can also define compile time macros required for the part to be enabled. The format for writing the _DSTR can be found here: :ref:`cond_spec` .

* Description:

    Macro to indicate the start of the test case.

* Usage:

.. code-block:: c

    RVTEST_CASE_START(1,"check ISA:=regex(.*I.*); check ISA:=regex(.*C.*); def TEST_CASE_1=True")

**RVTEST_SIGBASE( _R, _TAG )**

* Arguments:

    * _R: The register to use as the base register pointing to the signature data-section.

    * _TAG: The tag containing the address of the signature section.

* Description:

    This macro initializes the register (_R) with the value of tag (_TAG) which is meant to point to
    the signature area. The offset is reset to 0x0.

* Usage:

.. code-block:: c

    RVTEST_SIGBASE(X26, test_B_res)

**RVTEST_SIGUPD(_BR, _R, _AVAL)**

* Arguments:

    * _BR: The base register pointing to the signature section.

    * _R: The register whose value needs to be stored to the signature.

    * _AVAL: The assertion value for the register, used internally by the RVMODEL_IO_ASSERT macro.

* Description:

    Macro to store the value contained in a register using the base register specified an offset and increment the offset. 

* Usage:

.. code-block:: c

    RVTEST_SIGUPD(x2, x3, 0x00000000)


Standard MODEL Macros
---------------------

These are the list of model-based macros which can be modified by the model based on the platform
dependencies.

**RVMODEL_DATA_SECTION**

* Arguments: None

* Description:

    Macro containing the data section for the model for auxillary purposes.

**RVMODEL_DATA_BEGIN**

* Arguments: None

* Description:

    Macro indicating the start of the signature section of the test.

**RVMODEL_DATA_END**

* Arguments: None

* Description:

    Macro indicating the end of the signature section of the test. All signature pertaining to the test must be contained inbetween the *RVMODEL_DATA_BEGIN* and *RVMODEL_DATA_END* macro pair.

**RVMODEL_BOOT**

* Arguments: None

* Description:

    Macro containing the boot code for the model(can be an empty macro).

**RVMODEL_HALT**

* Arguments: None

* Description:

    Macro to halt the target machine.

**RVMODEL_IO_INIT**

* Arguments: None

* Description:

    Macro to initialise the IO for the target machine. (To be used for debugging)

**RVMODEL_IO_CHECK**

* Arguments: None

* Description:

    Macro to check the IO. (To be used for debugging)

**RVMODEL_IO_WRITE_STR(_SR, _STR)**

* Arguments:

    * _SR: The scratch register to be used to hold the address of the temporary stack.

    * _STR: The string which should be written.

* Description:

    Macro to write string to the debug output. 

* Usage:

.. code-block:: c

    RVMODEL_IO_WRITE_STR(x31,"My custom String")


**RVMODEL_IO_ASSERT_GPR_EQ(_SR, _R, _AVAL)**

* Arguments:

    * _SR: The scratch register to be used to hold the address of the temporary stack.

    * _R: The register whose value needs to be checked.

    * _AVAL: The assert value for the register.

* Description:

    Macro to check whether the register value(_R) is equal to a specific value(_AVAL) and display output as defined.

* Usage:

.. code-block:: c

    RVMODEL_IO_ASSERT_GPR_EQ(x31, x2, 0xDEADBEEF)

Example
-------
.. code-block:: c

    RVTEST_ISA("RV32I")
    RVMODEL_RV32M

    # Test code region.
    RVTEST_CODE_BEGIN

    RVMODEL_IO_INIT
    RVMODEL_IO_WRITE_STR(x31, "# Test Begin\n")

    # ---------------------------------------------------------------------------------------------
    #ifdef TEST_CASE_1
    RVTEST_CASE(1,"check ISA:=regex(.*I.*); \
                        def TEST_CASE_1=True")
    RVMODEL_IO_WRITE_STR(x31, "# Test part A1 - general test of value 0 with 0, \
                        1, -1, MIN, MAX register values\n");

    # Addresses for test data and results
    la      x1, test_A1_data
    RVTEST_SIGBASE(x2, test_A1_res)

    # Load testdata
    lw      x3, 0(x1)

    # Register initialization
    li      x4, 0
    li      x5, 1
    li      x6, -1
    li      x7, 0x7FFFFFFF
    li      x8, 0x80000000

    # Test
    add     x4, x3, x4
    add     x5, x3, x5
    add     x6, x3, x6
    add     x7, x3, x7
    add     x8, x3, x8

    # Store results
    RVTEST_SIGUPD(x2, x3, 0x00000000)
    RVTEST_SIGUPD(x2, x4, 0x00000000)
    RVTEST_SIGUPD(x2, x5, 0x00000001)
    RVTEST_SIGUPD(x2, x6, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x7, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x8, 0x80000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A1  - Complete\n");
    #endif
    RVMODEL_HALT

    RVTEST_CODE_END

    test_A1_data:
        .word 0

    RVMODEL_DATA_BEGIN

    test_A1_res:
        .fill 6, 4, -1

    RVMODEL_DATA_END




