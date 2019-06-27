
# This tests the delegation/no-delegation feature of the illegal_instruction_exception
# Do not execute test part 6 before other tests as it may change the working mode to S mode. 
# In general, tests should be conducted in order.

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

#define MISA_SUP        18
#define MISA_USR        20
#define MSTATUS_MPP_BIT 11

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M 

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")
    
    // Assert
    
    RVTEST_START

    la      s0 , test_res
    #---------------------------------------------------------------------------------------------  
    RVTEST_PART_START(1, "Check if reading mstatus causes an exception");

    # Set Test Flag
    li      s1, 0
    csrr    s2, mstatus
        
    # check if an exception was raised by checking if the value of s1 changed
    bnez    s1, test_end
    
    RVTEST_PART_END(1) 

    #---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(2, "Check if mstatus.mie is hardwired\n");
    
    # set to 1 
    li      t4, MSTATUS_MIE
    csrs    mstatus, t4
    
    # clear and check
    csrr    t3, mstatus
    li      t4, MSTATUS_MIE
    csrc    mstatus, t4
    csrr    t4, mstatus
    # should have changed
    beq     t3, t4, test_end
    
    # set and check
    csrr    t3, mstatus
    li      t4, MSTATUS_MIE
    csrs    mstatus, t4
    csrr    t4, mstatus
    # should have changed
    beq     t3, t4, test_end
    
    RVTEST_PART_END(2)
    
    #---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(3, "Check if mstatus.mpie is hardwired\n");
    
    # set to 1 
    li      t4, MSTATUS_MPIE
    csrs    mstatus, t4
    
    # clear and check
    csrr    t3, mstatus
    li      t4, MSTATUS_MPIE
    csrc    mstatus, t4
    csrr    t4, mstatus
    # should have changed
    beq     t3, t4, test_end
    
    # set and check
    csrr    t3, mstatus
    li      t4, MSTATUS_MPIE
    csrs    mstatus, t4
    csrr    t4, mstatus
    # should have changed
    beq     t3, t4, test_end
    
    RVTEST_PART_END(3)
     
    #---------------------------------------------------------------------------------------------  
    RVTEST_PART_START(4, "Check if mstatus.mpp can be set to M\n");

    # set mpp to M
    csrc    mstatus, t0
    li      t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_M     # Does this require multiplication
    csrs    mstatus, t5
    
    # check if it is set to M
    li      t4, MSTATUS_MPP
    and     t5, t5, t4
    srl     t5, t5, MSTATUS_MPP_BIT
    li      t4, PRV_M
    bne     t4, t5, test_end
    
    
    RVTEST_PART_END(4)
    
    #---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(5, "Check if mstatus.mpp can be set to S\n");
    RVTEST_PART_SKIP(5, "MISA_S_WARL_fn: [WARL_fn, 0]");
     
    # skip if no supervisor mode
    #li      t5, 1 << MISA_SUP
    ##csrr    t4, misa; RVTEST_REG_WRITE(t4)
    #csrs    misa , t5
    #csrr    t5, misa
    ##RVTEST_REG_WRITE(t5)
    #srl     t5, t5, MISA_SUP
    #andi    t5, t5, 1
    #beqz    t5, test_end    # change this !!
    
    li  t4, -1
    RVTEST_REG_WRITE(t4)    # THIS SHOULD BE DONE AUTOMATICALLY
    j   test_part_6         # ISINT THIS A BUG????
    
    # set mpp to M
    csrc    mstatus, t0
    li      t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_M     # Does this require multiplication
    csrs    mstatus, t5
    
    # check if it is set to M
    li      t4, MSTATUS_MPP
    and     t5, t5, t4
    srl     t5, t5, MSTATUS_MPP_BIT
    li      t4, PRV_M
    bne     t4, t5, test_end
    
    
    RVTEST_PART_END(5)
    
    #---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(6, "Check if mstatus.mpp can be set to U\n");
    RVTEST_PART_SKIP(6, "MISA_S_WARL_fn: [WARL_fn, 0]");
     
    # skip if no user mode
    li      t5, 1 << MISA_USR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_USR
    andi    t5, t5, 1
    beqz    t5, test_end    # change this if not last !!
    
    # set mpp to U
    csrc    mstatus, t0
    li      t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_U     # Does this require multiplication
    csrs    mstatus, t5
    
    # check if it is set to M
    li      t4, MSTATUS_MPP
    and     t5, t5, t4
    srl     t5, t5, MSTATUS_MPP_BIT
    li      t4, PRV_U
    bne     t4, t5, test_end
    
    
    RVTEST_PART_END(6)
    
    #---------------------------------------------------------------------------------------------   
    #---------------------------------------------------------------------------------------------   
#---------------------------------------------------------------------------------------------   
        
    j       test_end

# machine mode trap handler & Returns to machine mode permanently  

mtvec_handler:

    # increment return address
    csrr    x30 , mepc
    addi    x30 , x30 , 4
    csrw    mepc , x30    

    # Store MCAUSE
    csrr    t5 , mcause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end
    
    # Change Flag
    addi    s1 , s1, 1
    
    mret

# --------------------------------------------------------------------------------------------- 
    # End test
    
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
    .fill 8, 4, -1

RV_COMPLIANCE_DATA_END
