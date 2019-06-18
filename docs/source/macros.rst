.. _test_macros:

Test Macros
^^^^^^^^^^^

**RVTEST_ISA(_STR)**

Empty macro to specify the isa required for compilation of the test. It takes one argument namely a string containing the ISA confirming to the latest RISCV ISA specification(_STR).
This is the first macro which the dbgen module looks for and is mandated to be present at the start of the test.

Example:

.. code-block:: c

    RVTEST_ISA("RV32IC")

**RV_COMPLIANCE_CODE_BEGIN**

Macro to indicate the start of the code block in the test and add the startup routine for the test. 
No part of the code section should precede this macro. 

**RV_COMPLIANCE_CODE_END**

Macro to indicate the end of the code block in the test.

**RV_COMPLIANCE_HALT**

Macro to add the code to halt the machine.

**RVTEST_IO_INIT**

Macro to initialise the IO for the test. (To be used for debugging)

**RVTEST_IO_WRITE_STR(_R, _STR)**

Macro to write string to the debug output. It takes two arguments namely a register(_R) and an output string(_STR). 

Example:

.. code-block:: c

    RVTEST_IO_WRITE_STR(x31,"Example String")

**RVTEST_CASE_START(_PNAME,_DSTR)**

Macro to indicate the start of the test part. It takes two arguments namely part name(_PNAME) and the string specifying the conditions in which this part is enabled and the macros required for the part to run(_DSTR). The format for writing the _DSTR can be found here: :ref:`cond_spec` .

Example:

.. code-block:: c

    RVTEST_CASE_START(1,"check ISA:=regex(.*I.*); check ISA:=regex(.*C.*); def TEST_PART_1=True")

**RVTEST_CASE_END(_PNAME)**

Macro to indicate the end of a test part. It takes one argument namely the part name(_PNAME). A part which should be contained within the *RVTEST_CASE_START* and *RVTEST_CASE_END* macro pair and no nested parts are allowed. The _PNAME in the macro pairs must match. There should be atleast one test part in a test.

Example:

.. code-block:: c

    RVTEST_CASE_END(1)

**RVTEST_SIGBASE(_R,_TAG)**

Macro to define the register used as a pointer to the output signature area and initialise it with the appropriate value. It takes two arguments namely the register to use as pointer(_R) and the tag containing the address of the signature section(_TAG).

Example:

.. code-block:: c

    RVTEST_SIGBASE(X26, test_B_res)

**RVTEST_SIGUPDATE(_R,_AVAL)**

Macro to store the value contained in a register using the base register specified in the 
*RVTEST_SIGBASE* macro and an offset and increment the offset. Optionally, the macro can invoke a test assertion macro(currently *RVTEST_IO_ASSERT_GPR_EQ*) with the assertion value. It takes two arguments namely the register whose value needs 
to be stored(_R) and the assertion value(_AVAL). 

Example:

.. code-block:: c

    RVTEST_SIGUPDATE(X3, 0x00000000)

**RV_COMPLIANCE_DATA_BEGIN**

Macro indicating the start of the data section of the test.

**RV_COMPLIANCE_DATA_END**

Macro indicating the end of the data section of the test. All data pertaining to the test must be contained inbetween the *RV_COMPLIANCE_DATA_BEGIN* and *RV_COMPLIANCE_DATA_END* macro pair.

Example
^^^^^^^^
.. code-block:: none

    #include "compliance_test.h"
    #include "compliance_io.h"
    #include "test_macros.h"

    RVTEST_ISA("RV32I")
    RV_COMPLIANCE_RV32M

    # Test code region.
    RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_SIGBASE(x2)
    RVTEST_IO_WRITE_STR(x31, "# Test Begin\n")

    # ---------------------------------------------------------------------------------------------
    RVTEST_CASE_START(1,"check ISA:=regex(.*I.*); \
                        def TEST_PART_1=True")
    RVTEST_IO_WRITE_STR(x31, "# Test part A1 - general test of value 0 with 0, \
                        1, -1, MIN, MAX register values\n");

    # Addresses for test data and results
    la      x1, test_A1_data
    la      x2, test_A1_res

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
    sw      x3, 0(x2)
    sw      x4, 4(x2)
    sw      x5, 8(x2)
    sw      x6, 12(x2)
    sw      x7, 16(x2)
    sw      x8, 20(x2)

    //
    // Assert
    //
    RVTEST_IO_CHECK()
    RVTEST_SIGUPDATE(x3, 0x00000000)
    RVTEST_SIGUPDATE(x4, 0x00000000)
    RVTEST_SIGUPDATE(x5, 0x00000001)
    RVTEST_SIGUPDATE(x6, 0xFFFFFFFF)
    RVTEST_SIGUPDATE(x7, 0x7FFFFFFF)
    RVTEST_SIGUPDATE(x8, 0x80000000)

    RVTEST_IO_WRITE_STR(x31, "# Test part A1  - Complete\n");
    RVTEST_CASE_END(1)
    RV_COMPLIANCE_HALT

    RV_COMPLIANCE_CODE_END

    test_A1_data:
        .word 0

    RV_COMPLIANCE_DATA_BEGIN

    test_A1_res:
        .fill 6, 4, -1
    
    RV_COMPLIANCE_DATA_END




