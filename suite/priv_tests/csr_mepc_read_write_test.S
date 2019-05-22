# Description: Testing undefined machine csr



#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

#define XLEN_VAL 64
#define MISA_SUPERVISOR 18
#define MISA_C 2

.option norvc

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

// Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")

    // Initialize part number and signature address
    RVTEST_START

    // todo: is this necessary ?   
    RVTEST_IO_CHECK()


    // Spec: The low bit of mepc (mepc[0]) is always zero.
    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(1, "# Check mepc[0] = 0")

    csrr t2, mepc
    li t5, 1
    csrs mepc, t5
    csrr t5, mepc
    bne t2, t5, test_end
        
    RVTEST_PART_END(1)

    // Spec: The low bit of mepc (mepc[0]) is always zero.
    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(2, "# Check mepc[0] = 0 on misa.C = 0 ")
    RVTEST_PART_SKIP(2, "MISA_C: 1")

    // Resetting misa.c
    li t4, 1 << MISA_C
    csrc misa, t4
    csrr t4, misa
    srli t4, t4, MISA_C
    andi t4, t4, 1
    bnez t4, test_part_3

    // setting mepc[0] and reading it as 0
    csrr    t2, mepc
    li      t5 , 1
    csrs    mepc , t5
    csrr    t5, mepc
    bne    t2, t5, test_end // test fails if reads mepc[0]=1

    RVTEST_PART_END(2)

    // Spec: The low bit of mepc (mepc[0]) is always zero.
    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(3, "# Check mepc[0] = 0 on misa.C = 1 ")
    RVTEST_PART_SKIP(3, "MISA_C: 0")

    // Setting misa.c
    li t4, 1 << MISA_C
    csrs misa, t4
    csrr t4, misa
    srli t4, t4, MISA_C
    andi t4, t4, 1
    beqz t4, test_part_4

    # setting mepc[0] and reading it as 0
    csrr    t2, mepc
    li      t5 , 1
    csrs    mepc , t5
    csrr    t5, mepc
    bne     t2, t5, test_end 

    RVTEST_PART_END(3)

    // Spec: The low bits of mepc (mepc[1]) is zero on IALIGN=32 (non compressed)
    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(4, "# Check mepc[1] = 0 on misa.C = 0 ")
    RVTEST_PART_SKIP(4, "MISA_C: 1")

    // Resetting misa.c
    li t4, 1 << MISA_C
    csrc misa, t4
    csrr t4, misa
    srli t4, t4, MISA_C
    andi t4, t4, 1
    bnez t4, test_part_5

    // setting mepc[1] and reading it as 0
    csrr    t2, mepc
    li      t5 , 2
    csrs    mepc , t5
    csrr    t5, mepc
    bne     t2, t5, test_end 
   
    RVTEST_PART_END(4)

    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(5, "# Write/Read Check");

    // write mepc and check reading
    li      t5 , 0xdeadab40
    csrw    mepc, t5
    csrr    t2, mepc
    bne     t2, t5, test_end

    RVTEST_PART_END(5)

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
    .fill 5, 4, -1

RV_COMPLIANCE_DATA_END
