
# Description: Testing WLRL bits in misa.Checks if an illegal write changes values of WLRL bits.Test is skipped if misa does not exit
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
    RVTEST_START
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(1, "# Check misa addr 0x301"); 
    RVTEST_PART_SKIP(1, "# MISA ,0");
    # Test1
    csrr   t2,0x301
    beqz   t2,test_end #skipping test if misa not implemented
    li     x9,0x38000000 # extracting WLRL bits
    and    x9,t2,x9
    srli   x8,x9,0x1B
    addi   x8,x8,1 # x8 should contain illegal value
    slli   x8,x8,0x1B
    csrc   0x301,x8
    csrr   t3,0x301
    bne    t3,t2,test_end
    # go to test_end if  successfull 
    RVTEST_PART_END(1)
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

test_res:
    .fill 4, 4, -1

RV_COMPLIANCE_DATA_END
