// -------------------------------------------------------------------------------------------------
// Description: Testing csr misa.M bit for mul configuration
// -------------------------------------------------------------------------------------------------

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

    //-------------------------------------------------------------------------------   
    RVTEST_PART_START(1, " Set misa.M=0, check mul takes illegal instruction\n")
    RVTEST_PART_SKIP(1, "LEGAL_1")
 
    // mask for m extension bit
    li t2, 0x1000

    // clear misa.M and read
    csrc misa, t2
    csrr t6, misa

    // separating the twelfth  bit
     srl t6, t6, 12
     andi t6, t6, 0x01

    // checking if the read bit is still zero
    // skips this part on misa.M hardwaried to 1'b1
    bnez t6, test_part_2 
    
    // executing multiply instruction
    li t4, 0x4
    li t5, 0x2
    //.word 0x02a28333
    mul t1, t5, t4

    j test_end     // test fail if exception not taken
    
    RVTEST_PART_END(1)

    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(2, " Try set misa.M=0, if misa.M is hardwired to 1 execute multiplication else skip\n")
    RVTEST_PART_SKIP(2, "LEGAL_0")
    RVTEST_PART_SKIP(2, "LEGAL_01")

    // mask for m extension bit
    li t2, 0x1000

    // clear misa.M and read
    csrc misa, t2
    csrr t6, misa
    
    // separating the twelfth  bit
    srl t6, t6, 12
    andi t6, t6, 0x01

    // checking if the read bit is still zero
    beqz t6, test_part_3

    // executing multiply instruction
    li t4, 0x4
    li t5, 0x2
    //.word 0x02a28333
    mul t1, t5, t4
    // checking functionality
    j 1f
    j test_end
1:
    li x8, 0x8
    bne t1, x8, test_end
    
    RVTEST_PART_END(2)
    
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(3, " Try set misa.M=1, if misa.M is hardwired to 0 execute multiplication and reach exception else skip \n")
    RVTEST_PART_SKIP(3, "LEGAL_1")
    RVTEST_PART_SKIP(3, "LEGAL_01")
    
    // mask for m extension bit
    li t2, 0x1000
    
    // set misa.M and read
    csrs misa, t2
    csrr t6, misa
    
    // separating the twelfth  bit
    srl t6, t6, 12
    andi t6, t6, 0x01
   
    // checking if the read bit is still one
    bnez t6, test_part_4
     
    // executing multiply instruction
    li t4, 0x5
    li t5, 0x2
    //.word 0x02a28333
    mul t1, t5, t4
    j test_end

    
    RVTEST_PART_END(3)

    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(4, " Set misa.M=1, checks when misa.M is read as 1\n")
    RVTEST_PART_SKIP(4, "LEGAL_0")
    
    // mask for m extension bit
    li t2, 0x1000
    
    // set misa.M and read
    csrs misa, t2
    csrr t6, misa
    
    // separating the twelfth  bit
    srl t6, t6, 12
    andi t6, t6, 0x1

    //checking if the read bit is still one
    beqz t6, test_end
    //executing multiply instruction
    li t4, 0x1
    li t5, 0xc
    //.word 0x02a28333
    mul t1, t5, t4
    j 1f
    //checking functionality
    j test_end
1:
    li t5, 0xc
    bne t1, t5, test_end
    
    RVTEST_PART_END(4)

    // ---------------------------------------------------------------------------------------------
    
    j test_end

// Exception handler
mtvec_handler:

    // increment return address
    csrr    x30 , mepc
    lh      x31, (x30) // fetching instruction
    andi x31, x31, 0x3 // check the lower 2 bits to see if the instruction is 32-bit or 16-bit.
    li t6, 0x3
    bne x31,t6,m1_inst16
m1_inst32:                           // is 32-bit instruction then increment by 4
    addi x30,x30, 0x4
    j 1f
m1_inst16:
    addi x30,x30, 0x2                  // is 16-bit instruction then increment by 2
1: 

    lh      x31, (x30) // fetching instruction
    andi x31, x31, 0x3 // check the lower 2 bits to see if the instruction is 32-bit or 16-bit.
    li t6, 0x3
    bne x31,t6,m2_inst16
m2_inst32:                           // is 32-bit instruction then increment by 4
    addi x30,x30, 0x4
    j 1f
m2_inst16:
    addi x30,x30, 0x2                  // is 16-bit instruction then increment by 2
1: 

    csrw mepc, x30                   // point mepc to the next instruction.

    // Store MCAUSE
    csrr    t5 , mcause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    // Reformatting mstatus to keep in machine mode
    li      t5, MSTATUS_MPP
    csrs    mstatus , t5
   
    li      s1 , 3
    mret


test_end:
    RVTEST_IO_WRITE_STR("// Test End\n")

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
