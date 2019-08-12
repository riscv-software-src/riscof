// Description: Verifying MXL in misa on nmi reset

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

// Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

// Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")

    // Assert
    
    RVTEST_START
    
    // test end if reading misa returns 0
    csrr t2, misa 
    beqz t2, test_end

    // Address for test results
    la      s0, test_res

    //placing immediate 4 in a register.
    li s2, 4

    // ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(1, "# Test part passes if MXL = 1 on nmi reset");

    // Test
    csrr    s1, misa
    srli    s1, s1, 30
    andi    s1, s1, 0x3

    //shifting the register left by 31 bits at a time
    slli s2,s2,31 

    //check for RV32
    bnez s2, test_part_2
    li t2, 1
    bne s1, t2, test_end

    RVTEST_PART_END(1)
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(2, "# Test part passes if MXL = 2 on nmi reset");

    // Test
    csrr    s1, misa
    srli     s1, s1, 62
    andi    s1, s1, 0x3

    //shifting the register left by 31 bits second time
    slli s2,s2,31 

    //check for RV32
    bnez s2, test_part_3
    li t2, 2
    bne s1, t2, test_end

    RVTEST_PART_END(2)  
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(3, "# Test part passes if MXL = 3 on nmi reset");

    // Test
    csrr    s1, misa
    li      t2, 126   
    srl     s1, s1, t2
    andi    s1, s1, 0x3
    li      t2 , 3
    bne     s1, t2, test_end

    RVTEST_PART_END(3)
 // ---------------------------------------------------------------------------------------------
test_end:

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
    .fill 1, 4, -1

RV_COMPLIANCE_DATA_END
