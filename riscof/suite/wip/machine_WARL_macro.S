# Description: Testing WARL bits in misa

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"
# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

# Test code region
    RV_COMPLIANCE_CODE_BEGIN
    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
    //
    // Assert
    //
    RVTEST_IO_CHECK()
    
    .option norvc
    
    # Address for test results
    # ---------------------------------------------------------------------------------------------
    RVTEST_IO_WRITE_STR("# Test part A1 - check mxl in misa");
    
    # Test
    
    li     x2,0x01
    TEST_WARL(0x301,0x20,0x2,0x00,0x0000,0xC000,x8,x9,x12,0x20)
    bne   x12,x2,test_end#Check if read is ignored(1,2,3 are legal values)
    li    x2,0x01;
    la    x11, test_A_res_exc
    sb    x2,0(x11);
    RVTEST_IO_WRITE_STR("# Test part A1  - Complete\n");
    # ---------------------------------------------------------------------------------------------
    # ---------------------------------------------------------------------------------------------
    test_end:
    RVTEST_IO_WRITE_STR("# Test End\n")
 # ---------------------------------------------------------------------------------------------
    # HALT
    RV_COMPLIANCE_HALT
    RV_COMPLIANCE_CODE_END

# Input data section.
    .data
    .align 4

# Output data section.
RV_COMPLIANCE_DATA_BEGIN
    .align 4

test_A_res_exc:
    .fill 4, 4, -1

RV_COMPLIANCE_DATA_END
