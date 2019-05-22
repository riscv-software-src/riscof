# Description: mtvec check
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
    
    RVTEST_START
    # Address for test results
    # ---------------------------------------------------------------------------------------------
       
    RVTEST_PART_START(1, "# Check legal values for csr address 0x305");
    #RVTEST_PART_SKIP(1, "# MISA,0"); 
    # Test1 : check if base and mode has legal values
    csrr t5,0x305
    li t3,0x03
    and t4,t5,t3
    li t3,0x01
    bge t4,t3,test_end
    li t3,0x00
    srli t2,t5,0x02
    bne t4,t3,test_end
    csrw 0x305,t5
    RVTEST_PART_END(1)
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(2,"# WARL check for mtvec");
    csrr t2,0x305
    li t3,0x0003  # setting mode bit to 3
    csrs 0x305,t3
    csrr t4,0x305
    andi t4,t4,0x03
    beq t4,t3,test_end
    csrw 0x305,t2
    # ---------------------------------------------------------------------------------------------
    test_2:
    RVTEST_PART_END(2) 
    
    test_end:
    RVTEST_IO_WRITE_STR("# Test End\n")
 # -------------------------------------------------------------------------------------------------
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
