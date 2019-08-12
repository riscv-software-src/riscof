# Description: Testing undefined machine csr

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) t0(x5) t1(x6) gp(x3) sp(x2) \n")

    // Assert
    RVTEST_IO_CHECK()
    
    .option norvc
    
    RVTEST_START
    
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(1, "# Check machine csr addr 0x307");
    RVTEST_PART_SKIP(1, "# MISA_M: LEGAL_0\n"); 
    csrw 0x307, t1
    j test_end 
    
    RVTEST_PART_END(1) 

    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(2, "# Check machine csr addr 0x308");
    
    csrw 0x308, t1
    j test_end 
    
    RVTEST_PART_END(2) 
       
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(3, "# Check machine csr addr 0x309");
    
    csrw 0x309, t1
    j test_end 
    
    RVTEST_PART_END(3) 
    
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(4, "# Check machine csr addr 0x30a");
    
    csrw    0x30a, t2
    j test_end 
    
    RVTEST_PART_END(4) 
    
    # ---------------------------------------------------------------------------------------------
    j test_end


    # ---------------------------------------------------------------------------------------------
    # Exception handler
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
