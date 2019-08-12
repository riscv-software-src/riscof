// -------------------------------------------------------------------------------------------------
// Description: Testing csr misa.F bit for single precision floating point configuration
// -------------------------------------------------------------------------------------------------

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

// Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

// Test code region

RV_COMPLIANCE_CODE_BEGIN

#define MISA_F 0x5
#define MSTATUS_FS0 13
 
    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")

    // Assert
    RVTEST_START

    // test end if reading misa returns 0
    csrr t2, misa 
    beqz t2, test_end

	
    // setting mstatus.FS = 1 and reading it as 1 [more info at page number 23, priv-spec v 1.11 draft]
    li      t5, 1 << MSTATUS_FS0
    csrs    mstatus , t5
    csrr    t5, mstatus
    srl     t5, t5, MSTATUS_FS0
    andi    t5, t5, 1
    li      t2, 1
    bne     t5, t2, test_end
    
    // Address for test results
    la      s0, test_res
    li      s1, 1<<MISA_F
    j       1f

.align 4
test_area:
    nop
    nop
    nop
    nop
	
1:  
    //--------------------------------------------------------------------------------------
    RVTEST_PART_START(1, " Set misa.F=0, check single precision floating takes illegal instruction\n")
    RVTEST_PART_SKIP(1, "LEGAL_1")

    // clear misa.C and read
    csrc misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_F

    // checking if the read bit is still zero
    // skips this part on misa.M hardwaried to 1'b1
    bnez t2, test_part_2
    
    // executing single precision floating instruction
    li    s3, 0xff
    la    t5, test_area
    flw   f2, (t5)
    li    s2, 0x3
    bne   s3, s2, test_end
    
    RVTEST_PART_END(1)
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(2, " Try setting misa.F=0, skip when misa.F is not hardwired to 1\n")
    RVTEST_PART_SKIP(2, "LEGAL_0")
    RVTEST_PART_SKIP(2, "LEGAL_01")
    
    // clear misa.F and read
    csrc misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_F
    
    // checking if the read bit is still zero
    beqz t2, test_part_3

    // executing single precision floating instruction
    li    s3, 0xff
    la    t5, test_area
    flw   f2, (t5)
    li    s2, 0xff
    bne   s3, s2, test_end
    
    RVTEST_PART_END(2)
    // ---------------------------------------------------------------------------------------------
 
    RVTEST_PART_START(3, " Try setting misa.F=1, skip when misa.F is not hardwired to 0\n")
    RVTEST_PART_SKIP(3, "LEGAL_1")
    RVTEST_PART_SKIP(3, "LEGAL_01")
    
    // set misa.F and read
    csrs misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_F

    // checking if the read bit is still one
    bnez t2, test_part_4
     
    // executing single precision floating instruction
    li    s3, 0xff
    la    t5, test_area
    flw   f2, (t5)
    li    s2, 0x3
    bne   s3, s2, test_end
    
    RVTEST_PART_END(3)
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(4, " Set misa.F=1, checks when misa.F is read as 1\n")
    RVTEST_PART_SKIP(4, "LEGAL_0")

    // set misa.F and read
    csrs misa, s1
    csrr t2, misa
    
    // separating the second  bit
    andi t2, t2, 1<<MISA_F
    
    //checking if the read bit is still one
    beqz t2, test_end

    // executing single precision floating instruction
    li    s3, 0xff
    la    t5, test_area
    flw   f2, (t5)
    li    s2, 0xff
    bne   s3, s2, test_end  
    
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
    csrw mepc, x30                   // point mepc to the next instruction.

    // Store MCAUSE
    csrr    t5 , mcause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    // Reformatting mstatus to keep in machine mode
    li      t5, MSTATUS_MPP
    csrs    mstatus , t5
   
    li      s3 , 3
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
