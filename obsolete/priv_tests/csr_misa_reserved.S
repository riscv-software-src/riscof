// -------------------------------------------------------------------------------------------------
// Description: Testing csr reserved bits
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
    //All bits that are reserved for future use must return zero when read.
    // ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(1,"# Test part A1 - misa reserved bit 7\n");

    // Test
    // Reserved Bit 7

    // Try to set it
    li t2, 0x80
    csrs misa, t2
    csrr t2, misa
    
    // Separating seventh bit
    srl t2, t2, 7   
    andi t2, t2, 01
   
    // checking if bit 7 reads zero
    bnez t2, test_part_2

    RVTEST_PART_END(1);
   
    // ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(2, "# Test part A2 - misa reserved bit 10\n");
    
    // Test
    // Reserved bit 10

    // Trying to set it
    li t2, 0x400     
    csrs misa, t2
    csrr t2, misa
    
    // Separating tenth bit
    srl t2, t2, 10    
    andi t2, t2,01
    
    // Checking if bit 10 reads zero
    bnez t2, test_part_3

    RVTEST_PART_END(2);
    // ---------------------------------------------------------------------------------------------
       
    RVTEST_PART_START(3, "# Test part A3 -misa reserved bit 14\n");
    
    // Test
    // Reserved bit 14

    // Trying to set it
    li t2, 0x4000
    csrw misa, t2
    csrr t2, misa
    
    // Separating bit 14
    srl t2, t2, 14    
    andi t2, t2, 01
    

    // Checking if bit 14 reads zero
    bnez t2, test_part_4

    RVTEST_PART_END(3);
    // ---------------------------------------------------------------------------------------------   
       
    RVTEST_PART_START(4, "// Test part A3 -misa reserved bit 17\n");
    
    // Test
    // Reserved bit 17

    // Trying to set it
    li t2, 0x20000
    csrw misa, t2
    csrr t2, misa
    
    // Separating bit 17
    srl t2, t2, 17    
    andi t2, t2, 01
    

    // Checking if bit 17 reads zero
    bnez t2, test_part_5

    RVTEST_PART_END(4);

    // ---------------------------------------------------------------------------------------------
    RVTEST_PART_START(5, "# Test part A3 -misa reserved bit 22\n");
    
    // Test
    // Reserved bit 22

    // Trying to set it
    li t2, 0x400000
    csrw misa, t2
    csrr t2, misa
    
    // Separating bit 22
    srl t2, t2, 22    
    andi t2, t2, 01
    

    // Checking if bit 22 reads zero
    bnez t2, test_part_6

    RVTEST_PART_END(5);
    // ---------------------------------------------------------------------------------------------

    RVTEST_PART_START(6, "# Test part A3 -misa reserved bit 24\n");
    
    // Test
    // Reserved bit 24

    // Trying to set it
    li t2, 0x1000000
    csrw misa, t2
    csrr t2, misa
    
    // Separating bit 24
    srl t2, t2, 24    
    andi t2, t2, 01
    

    // Checking if bit 24 reads zero
    bnez t2, test_part_7

    RVTEST_PART_END(6);
    // ---------------------------------------------------------------------------------------------
 
    RVTEST_PART_START(7, "# Test part A3 -misa reserved bit 25\n");
    
    // Test
    // Reserved bit 25

    // Trying to set it
    li t2, 0x2000000
    csrw misa, t2
    csrr t2, misa
    
    // Separating bit 25
    srl t2, t2, 25    
    andi t2, t2, 01

    // Checking if bit 25 reads zero
    bnez t2, test_end

    RVTEST_PART_END(7);

   // ---------------------------------------------------------------------------------------------
    j test_end


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
    .fill 8, 4, -1

RV_COMPLIANCE_DATA_END
