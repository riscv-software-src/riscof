#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

#define MSTATUS_MPP_INDEX 11
#define XLEN_VAL 64

.option norvc

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

// Test code region
RV_COMPLIANCE_CODE_BEGIN

#    RVTEST_IO_INIT
#    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
#    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")
#
#    // Initialize part number and signature address
    RVTEST_START
#
#    RVTEST_IO_CHECK()
    
    // Spec: xPP fields are WARL fields that can hold only privilege mode x and any implemented privilege
    // mode lower than x. If privilege mode x is not implemented, then x PP must be hardwired to 0.
    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(1, "# Check for illegal mode")

    li t0, MSTATUS_MPP
    csrc mstatus, t0
    li t5, (MSTATUS_MPP & -MSTATUS_MPP) * MPP_ILLEGAL
    csrs mstatus, t5
    csrr t2, mstatus
    srli t2, t2, MSTATUS_MPP_INDEX
    andi t2, t2, 3
    li t5, MPP_LEGAL_NEXT
    bne t2, t5, test_end

    RVTEST_PART_END(1)

// --------------------------------------------------------------------------------------------- 
test_end:
  
    RVTEST_IO_WRITE_STR("# Test End\n")

// ---------------------------------------------------------------------------------------------
    // HALT
    RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

// Input data section.
    .data
    .align 4

// Output data section.
RV_COMPLIANCE_DATA_BEGIN
    .align 4

test_res:
    .fill 1, 4, -1

RV_COMPLIANCE_DATA_END
