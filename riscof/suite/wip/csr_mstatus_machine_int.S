
# This tests the delegation/no-delegation feature of the illegal_instruction_exception
# Do not execute test part 6 before other tests as it may change the working mode to S mode. 
# In general, tests should be conducted in order.

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

#define MSIP_ADDR   0x2000000
#define MSIP_ENABLE 0x1
#define MIE_ENABLE  0x8
#define CAUSE_MSI   0x8000000000000003  
#define MISA_USR    20
#define MSTATUS_MPP_BIT 11

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")
    
    // Assert
    
    RVTEST_START

    la      s0 , test_res
    # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(1, "Check if interrupt happens MSTATUS.MIE, MIE.MSIE, MIP.MSIP are set to 1");

    # Set Test Flag
    li      s1, 0
    # Set MSTATUS.MIE, MIE.MSIE, MIP.MSIP to 1
    li      t3, MSTATUS_MIE
    csrs    mstatus, t3
    li      t3, MIE_ENABLE
    csrs    mie, t3
    li      t4, MSIP_ADDR
    li      t3, MSIP_ENABLE
    sw      t3, (t4)
    
    wfi
    # check if an interrupt had been handled, s1 would have the value of 
    # mcause when it was being handled
    beqz    s1, test_end
    
    RVTEST_PART_END(1) 

    #---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(2, "Check if mstatus had the correct value while being handled");
    
    # s1 has the value of MSTATUS while it was being handled
    # Check if MSTATUS.MPP = 11 (M)
    li      t3, MSTATUS_MPP
    and     t4, t3, s1
    bne     t4, t3, test_end
    
    # Check if MSTATUS.MIE = 0
    li      t3, MSTATUS_MIE
    and     t4, t3, s1
    bnez    t4, test_end
    
    RVTEST_PART_END(2) 

    #---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(3, "Check if mstatus had the correct value after being handled (if user mode is implemented)");
    RVTEST_PART_SKIP(3, "MISA_U_WARL_fn: [WARL_fn, 1]");
    
    # skip if no user mode
    li      t5, 1 << MISA_USR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_USR
    andi    t5, t5, 1
    beqz    t5, test_part_4
    
    # AUTO HANDLE SIGNATURE GENERATION
    
    # Check if MSTATUS.MPP = 00 (U)
    li      t4, MSTATUS_MPP
    and     t5, t5, t4
    srl     t5, t5, MSTATUS_MPP_BIT
    li      t4, PRV_U
    bne     t4, t5, test_end
    
    # Check if MSTATUS.MIE = 1
    li      t3, MSTATUS_MIE
    and     t4, t3, s1
    bne     t4, t3, test_end
    
    RVTEST_PART_END(3) 
    #--------------------------------------------------------------------------------------------- 
    RVTEST_PART_START(4, "Check if mstatus had the correct value after being handled (if user mode is not implemented)");
    RVTEST_PART_SKIP(4, "MISA_U_WARL_fn: [WARL_fn, 0]");
    
    # skip if user mode
    li      t5, 1 << MISA_USR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_USR
    andi    t5, t5, 1
    bnez    t5, test_end    # change this if not last !!
    
    # AUTO HANDLE SIGNATURE GENERATION
    
    # Check if MSTATUS.MPP = 11 (M)
    li      t4, MSTATUS_MPP
    and     t5, t5, t4
    srl     t5, t5, MSTATUS_MPP_BIT
    li      t4, PRV_M
    bne     t4, t5, test_end
    
    # Check if MSTATUS.MIE = 1
    li      t3, MSTATUS_MIE
    and     t4, t3, s1
    bne     t4, t3, test_end
    
    RVTEST_PART_END(4)  

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
    li      t2 , CAUSE_MSI
    bne     t5, t2, test_end

    ## Reformatting mstatus to keep in machine mode
    #li      t5, MSTATUS_MPP
    #csrs    mstatus , t5
    
    # Change Flag
    csrr    s1 , mstatus
    
    # Reset All    
    li      t3, MSTATUS_MIE   
    csrc    mstatus , t3                     
    li      t3, MIE_ENABLE
    csrc    mie, t3
    li      t4, MSIP_ADDR      
    li      t3, 0
    sw      t3, (t4)
    
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
