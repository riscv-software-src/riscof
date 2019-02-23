#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

#define XLEN_VAL 64
#define MSTATUS_MPP_INDEX 11

.option norvc

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

// Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
    RVTEST_IO_WRITE_STR(x31, "# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")

    // Initialize part number and signature address
    RVTEST_START

    RVTEST_IO_CHECK()
    
    // Spec: xPP fields are WARL fields that can hold only privilege mode x and any implemented privilege
    // mode lower than x. If privilege mode x is not implemented, then x PP must be hardwired to 0.
    // ---------------------------------------------------------------------------------------------   

    #ifdef TEST_PART_1
      RVTEST_PART_START(1)

      la x2, test_part1_res
   
      // write legal
      li t2, MSTATUS_MPP
      not t2, t2
      csrr t5, mstatus
      and t5, t5, t2
      li t3, LEGAL << MSTATUS_MPP_INDEX
      or t5, t5, t3
      csrw mstatus, t5

      // check for legal
      csrr t2, mstatus
      srli t2, t2, MSTATUS_MPP_INDEX
      andi t2, t2, 3

      sw t2, 0(x2)

      RVTEST_IO_ASSERT_GPR_EQ(x31, t2, LEGAL)

      RVTEST_PART_END(1)
    #endif

    // ---------------------------------------------------------------------------------------------   
    #ifdef TEST_PART_2
      RVTEST_PART_START(2)
      RVTEST_PART_RUN(2, "MSTATUS_MPP>distinct>modes:unchanged")
      
      la x2, test_part2_res
  
      // write legal
      li t2, MSTATUS_MPP
      not t2, t2
      csrr t5, mstatus
      and t5, t5, t2
      li t3, LEGAL << MSTATUS_MPP_INDEX
      or t5, t5, t3
      csrw mstatus, t5
      csrr t2, mstatus
      // write illegal
      li t2, MSTATUS_MPP
      not t2, t2
      csrr t5, mstatus
      and t5, t5, t2
      li t3, ILLEGAL << MSTATUS_MPP_INDEX
      or t5, t5, t3
      csrw mstatus, t5

      // check for legal
      csrr t2, mstatus
      srli t2, t2, MSTATUS_MPP_INDEX
      andi t2, t2, 3
      
      sw t2, 0(x2)

      RVTEST_IO_ASSERT_GPR_EQ(x31, t2, LEGAL)

      RVTEST_PART_END(2)
    #endif

    // ---------------------------------------------------------------------------------------------   
    #ifdef TEST_PART_3
      RVTEST_PART_START(3)
      RVTEST_PART_RUN(3, "MSTATUS_MPP>distinct>modes:saturate_s")
      
      la x2, test_part3_res

       // write legal
      li t2, MSTATUS_MPP
      not t2, t2
      csrr t5, mstatus
      and t5, t5, t2
      li t3, LEGAL << MSTATUS_MPP_INDEX
      or t5, t5, t3
      csrw mstatus, t5
      csrr t2, mstatus
      // write illegal
      li t2, MSTATUS_MPP
      not t2, t2
      csrr t5, mstatus
      and t5, t5, t2
      li t3, ILLEGAL << MSTATUS_MPP_INDEX
      or t5, t5, t3
      csrw mstatus, t5
   
      // check for legal
      csrr t2, mstatus
      srli t2, t2, MSTATUS_MPP_INDEX
      andi t2, t2, 3
      
      sw t2, 0(x2)
      addi  x2, x2, 4

      RVTEST_IO_ASSERT_GPR_EQ(x31, t2, LEGAL_SATURATE_S)

      RVTEST_PART_END(3)
    #endif
// --------------------------------------------------------------------------------------------- 
test_end:
  
    RVTEST_IO_WRITE_STR(x31,"# Test End\n")

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

#ifdef TEST_PART_1
  test_part1_res:
      .fill 1, 4, -1
#endif
#ifdef TEST_PART_2
  test_part2_res:
      .fill 1, 4, -1
#endif
#ifdef TEST_PART_3
  test_part3_res:
      .fill 1, 4, -1
#endif

RV_COMPLIANCE_DATA_END
