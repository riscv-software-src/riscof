
# This tests the delegation/no-delegation feature of the illegal_instruction_exception
# Do not execute test part 6 before other tests as it may change the working mode to S mode. 
# In general, tests should be conducted in order.

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

#define MISA_N      0x00002000
#define MSIP_ADDR   0x02000000
#define MSIP_ENABLE 0x00000001
#define MIE_ENABLE  0x00000008
#define UIE_ENABLE  0x00000002
#define CAUSE_MSI   0x8000000000000003  

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

    csrr    t3, mip
    RVTEST_REG_WRITE(t3)
    csrr    t3, mie
    RVTEST_REG_WRITE(t3)
    csrr    t3, mstatus
    RVTEST_REG_WRITE(t3)
    csrr    t3, misa
    RVTEST_REG_WRITE(t3)
    
    # Set Test Flag
    li      s1, 0
    # Set MISA_N to 1
    li      t3, MISA_N
    csrs    misa, t3
    # Set MSTATUS.MIE, MIE.MSIE, MIP.MSIP to 1
    li      t3, MSTATUS_SIE
    csrs    mstatus, t3
    li      t3, UIE_ENABLE
    csrs    mie, t3
    li      t3, UIE_ENABLE
    csrs    mip, t3
    wfi
    
    csrr    t3, mip
    RVTEST_REG_WRITE(t3)
    csrr    t3, mie
    RVTEST_REG_WRITE(t3)
    csrr    t3, mstatus
    RVTEST_REG_WRITE(t3)
    csrr    t3, misa
    RVTEST_REG_WRITE(t3)
    
    # check if an interrupt had been handled, s1 would have the value of 
    # mcause when it was being handled
    beqz    s1, test_end
    

    #---------------------------------------------------------------------------------------------   
    #---------------------------------------------------------------------------------------------   
    #---------------------------------------------------------------------------------------------  

#---------------------------------------------------------------------------------------------   
    
    j       test_end

# machine mode trap handler
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
    
# user exception handler
utvec_handler:

    # increment exception address
    #csrr    x30, uepc
    #addi    x30, x30, 4
    #csrw    uepc, x30

    # Store UCAUSE
    #csrr    s4 , ucause
    
    # Set MSTATUS.MIE, MIE.MSIE, MIP.MSIP to 0
    li      t3, MSTATUS_UIE
    csrc    mstatus, t3
    li      t3, UIE_ENABLE
    csrc    mie, t3
    li      t3, UIE_ENABLE
    csrc    mip, t3

    uret

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
