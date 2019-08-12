// -------------------------------------------------------------------------------------------------
// Description: Testing csr misa.C bit for compressed configuration
// -------------------------------------------------------------------------------------------------

.option norvc

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

// Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

// Test code region
RV_COMPLIANCE_CODE_BEGIN

#define MISA_C 0x2

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")

    // Assert
    RVTEST_START
    
    // Address for test results
    la      s0, test_res
    li      s1, 1<<MISA_C
    //--------------------------------------------------------------------------------------
    RVTEST_PART_START(1, " Set misa.C=0, check compressed takes illegal instruction\n")
    RVTEST_PART_SKIP(1, "LEGAL_1")

    // clear misa.C and read
     .align 2// if an instruction causes IALIGN to expand, the following instruction should be IALIGNed or misa write will be skipped
    csrc misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_C

    // checking if the read bit is still zero
    // skips this part on misa.M hardwaried to 1'b1
    bnez t2, test_part_2
    
    // executing compressed instruction
    //c.sub a1, a2
    .2byte 0x8d91
    .p2align 3
    j test_end     // test fail if exception not taken
        
    RVTEST_PART_END(1)
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(2, " Try setting misa.C=0, skip when misa.C is not hardwired to 1\n")
    RVTEST_PART_SKIP(2, "LEGAL_0")
    RVTEST_PART_SKIP(2, "LEGAL_01")
    
    // clear misa.C and read
    .align 2
    csrc misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_C
    
    // checking if the read bit is still zero
    beqz t2, test_part_3

    // executing compressed instruction
    li a2, 0x1111
    li a1, 0xffff
    //c.sub a1, a2
    .2byte 0x8d91
    .p2align 3
    // checking functionality
    j 1f
    j test_end
1:
    li a2, 0xeeee
    bne a1, a2, test_end
    
    RVTEST_PART_END(2)
    // ---------------------------------------------------------------------------------------------
 
    RVTEST_PART_START(3, " Try setting misa.C=1, skip when misa.C is not hardwired to 0\n")
    RVTEST_PART_SKIP(3, "LEGAL_1")
    RVTEST_PART_SKIP(3, "LEGAL_01")
    
    // set misa.C and read
    csrs misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_C

    // checking if the read bit is still one
    bnez t2, test_part_4
     
    // executing compressed instruction
    //c.sub a1, a2
    .2byte 0x8d91
    .p2align 3
    j test_end
    
    RVTEST_PART_END(3)
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(4, " Set misa.C=1, checks when misa.C is read as 1\n")
    RVTEST_PART_SKIP(4, "LEGAL_0")

    // set misa.C and read
    csrs misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_C
    
    //checking if the read bit is still one
    beqz t2, test_end

    //executing compressed instruction
    li a2, 0x1111
    li a1, 0xffff
    //c.sub a1, a2
    .2byte 0x8d91
    .p2align 3
    j 1f
    //checking functionality
    j test_end
1:
    li a2, 0xeeee
    bne a1, a2, test_end
    
    RVTEST_PART_END(4)

    // ---------------------------------------------------------------------------------------------
    
    j test_end
      
// Exception handler

mtvec_handler:    

    // increment return address
    csrr x30 , mepc
    addi x30,x30, 0x8                 
    csrw mepc, x30
                   
    // Store MCAUSE
    csrr    t5 , mcause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    // Reformatting mstatus to keep in machine mode
    li      t5, MSTATUS_MPP
    csrs    mstatus , t5
   
    mret

test_end:
    RVTEST_IO_WRITE_STR("# Test End\n")

 // ---------------------------------------------------------------------------------------------
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
