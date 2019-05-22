# Description: Testing undefined machine csr

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) t0(x5) t1(x6) \n")

    //
    // Assert
    //
    RVTEST_IO_CHECK()
    
    .option norvc
    # Address for test results
    la      t4, test_A_res_exc

    # ---------------------------------------------------------------------------------------------
    RVTEST_IO_WRITE_STR("# Test part A1 - \n");
    
    # Test
    li      t2, 0x1
    
    csrwi   medeleg, 0x1
    csrr    t3, medeleg
    la      t3, stvec_handler
    csrw    stvec, t3

    # Enter supervisor mode.
    la t3, 1f
    csrw mepc, t3
    li t3, MSTATUS_MPP
    csrc mstatus, t3
    li t3, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_S
    csrs mstatus, t3
    mret
1:
    la t3, 1f
    jalr x0, t3, 2
    j test_end 

1:
    sb      t2, 0(t4)
    RVTEST_IO_WRITE_STR("# Test part A1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    
    # ---------------------------------------------------------------------------------------------
    j test_end


    # ---------------------------------------------------------------------------------------------
    # Exception handler
stvec_handler:
    # increment return address
    csrr    x30, sepc
    addi    x30, x30, 8
    csrw    sepc, x30

    # Store SCAUSE
    li      x31, 0
    csrr    x30, scause
    bne     x30, x31, test_end

    # return
    sret

mtvec_handler:
    j test_end

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
