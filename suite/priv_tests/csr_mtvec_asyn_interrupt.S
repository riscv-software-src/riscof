# Description: Checks if asynchronous interrupts are vectored to right address in direct mode and vectored mode.This tests checks handler for machine external interrupt
#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"
# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV64M

# Test code region
    RV_COMPLIANCE_CODE_BEGIN
    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
    //
    // Assert
    //
    RVTEST_IO_CHECK()
    
    .option norvc
    
    RVTEST_START
    # Address for test results
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(1,"# Check asynchronous interrupts for address 0x305,mtvec");
    RVTEST_PART_SKIP(1, "# MTVEC HARDWIRED \n"); 
    # Test1 : check if asynchronous interrupts are vectored to base

    csrr t2,0x305
    la t3,direct_handler
    csrw 0x305,t3
    csrr t4,0x305
    beq t4,t2,test_end # Skip condition: mtvec hardwired
  #  wfi //TODO uncomment
    j test_end 
    RVTEST_PART_END(1)
    # ---------------------------------------------------------------------------------------------
test_2:
    RVTEST_PART_START(2,"# Check asynchronous interrupts for address 0x305,mtvec");
    RVTEST_PART_SKIP(2, "# MTVEC HARDWIRED \n"); 
    # Test1 : check if asynchronous interrupt are vectored to base+4*cause
    csrr t2,0x305
    la t3,handler
    csrw 0x305,t3
    li t4 ,0x01
    csrs 0x305,t4
    csrr t4,0x305
    beq t4,t2,test_end # Skip condition: mtvec hardwired
    li t5,0x0A
    slli t5,t5,0x2
    add t3,t3,t5 # vector location for external_interrupt
   # wfi //TODO uncomment
    j test_end 
    RVTEST_PART_END(2)

handler:
    jal trap_handler #0  
    jal trap_handler #1
    jal trap_handler #2
    jal trap_handler #3
    jal trap_handler #4
    jal trap_handler #5
    jal trap_handler #6
    jal trap_handler #7
    jal trap_handler #8
    jal trap_handler #9
    jal trap_handler #10
    auipc t4,0x00    #11
    bne t3,t4,test_end
    jal machine_ext_handler 
   
direct_handler:   
    auipc   t4,0x00
    bne     t3,t4,test_end
    csrr    x30, mepc
    addi    x30, x30, 8
    csrw    mepc,x30
    #return
    csrw 0x305,t2
    mret

trap_handler:
    csrr    x30, mepc
    addi    x30, x30, 8
    csrw    mepc,x30
    #return
    csrw 0x305,t2
    mret

machine_ext_handler:
    csrr    x30, mepc
    addi    x30, x30, 8
    csrw    mepc,x30
    #return
    csrw 0x305,t2
    mret

test_end:
    RVTEST_IO_WRITE_STR("# Test End\n")
 #---------------------------------------------------------------------------------------------------
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
