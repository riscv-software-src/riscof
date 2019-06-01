# Description: Testing WLRL bits in misa.Checks if an illegal value  writes generates exceptions into MISA.Test is skipped if misa does not exist
#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"
# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M
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
    # Address for test results
    # ---------------------------------------------------------------------------------------------
    RVTEST_START
    # RVTEST_PART_START(1,"WPRI_mstatus");
    # Test1
    #csrr   x8,mstatus;
    #andi   x9,x8,0xF7;
    #li x8,0x7F800624;   # masking one write bit and storing it in x9
    #csrs mstatus,x8;    # writing into mstatus WPRI fields
    #j test_2            # No illegal exception generated,test fails
    #RVTEST_PART_END(1)
    # ---------------------------------------------------------------------------------------------
    # ---------------------------------------------------------------------------------------------
       
    RVTEST_PART_START(1, "# Check if writes preserve values mstatus");
#Test1
    li x8,0x00000001
    csrc  mstatus,x8;   #Writing into adjacent read/write values
    csrs  mstatus,x8;   
    csrr  x8,mstatus;
    #Read mstatus and check if WPRI fields remain intact
    andi   x12,x8,0xF7;
    bne  x8,x12,test_end;  
    RVTEST_PART_END(1);

mtvec_handler:
    # increment return address
    csrr    x30, mepc
    addi    x30, x30, 8
    csrw    mepc, x30
    # Store MCAUSE
    li      x31, 2
    csrr    x30, mcause
    bne     x30, x31, test_end
    # return
    mret
    
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
    .fill 4, 4, -1

RV_COMPLIANCE_DATA_END
