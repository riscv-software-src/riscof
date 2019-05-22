# Description: Testing WARL bits in misa.Checks if an illegal value gets written into MISA.Test is skipped if misa does not exist
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
       
    RVTEST_PART_START(1, "# Check misa csr address 0x301");
    RVTEST_PART_SKIP(1, "# MISA,0"); 
    # Test1
    csrr   x8,0x301;
    beqz   x8,test_2; #skipping test if misa not implemented
    li     x8,0xC0000000
    csrc   0x301,x8
    csrr   x8,0x301
    srli   x9,x8,0x1E #shiftng right by 30
    li     t2,0x00
    beq    x9,t2,test_end #Check if read is ignored(1,2,3 are legal values)
    RVTEST_PART_END(1)
   
    # ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(2, "# Check machine csr addr 0x308");
    RVTEST_PART_SKIP(2, "# MISA,0");
       
    # ---------------------------------------------------------------------------------------------
    test_2:
  
    csrr   x8,0x301;
    beqz   x8,test_end;#skipping test if misa not implemented
    li     x8,0x07FFFFFF;
    csrs   0x301,x8;
    beq    x8,x9,test_end

    RVTEST_PART_END(2) 
       
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
