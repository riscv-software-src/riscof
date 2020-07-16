# RISC-V Compliance Test I-MISALIGN_JMP-01
#
# Copyright (c) 2017, Codasip Ltd.
# Copyright (c) 2018, Imperas Software Ltd. Additions
# Copyright (c) 2020, InCore Semiconductors Pvt. Ltd. Additions, Bug Fixes
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#      * Neither the name of the Codasip Ltd., Imperas Software Ltd. nor the
#        names of its contributors may be used to endorse or promote products
#        derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Codasip Ltd., Imperas Software Ltd.
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Specification: RV32I Base Integer Instruction Set, Version 2.0
# Description: Testing MISALIGNED JUMP exception.

#include "compliance_model.h"
#include "compliance_test.h"

# Test Virtual Machine (TVM) used by program.
RVTEST_ISA("RV32I")

# Test code region
RVMODEL_BOOT
RVTEST_CODE_BEGIN

    RVMODEL_IO_INIT
    RVMODEL_IO_ASSERT_GPR_EQ(x30, x0, 0x00000000)
    RVMODEL_IO_WRITE_STR(x30, "# Test Begin Reserved reg x31\n")

#ifdef TEST_CASE_1
    RVTEST_CASE(1,"// check ISA:=regex(.*32.*); check ISA:=regex(.*I.*C.*); def TEST_CASE_1=True;")
    RVTEST_CASE(2,"// check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); check ISA:=regex(^[^C]+$); def TEST_CASE_1=True;def rvtest_mtrap_routine=True;")
    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x30, "# Test part A1 - test JALR\n");

    # Address for test results
    la      x1, test_A1_res

        li      x2, 0x22222222
        la      x4, 1f
        jalr    x0, x4, 2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4
    
        li      x2, 0x33333333
        la      x4, 1f+1
        jalr    x0, x4, 1
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4


        li      x2, 0x44444444
        la      x4, 1f+2
        jalr    x0, x4, 0
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4

        li      x2, 0x55555555
        la      x4, 1f+3
        jalr    x0, x4, -1
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4

        li      x2, 0x66666666
        la      x4, 1f+4
        jalr    x0, x4, -2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4

    RVMODEL_IO_CHECK()
    RVMODEL_IO_WRITE_STR(x30, "# Test part A1  - Complete\n");
    RVMODEL_IO_WRITE_STR(x30, "# Test part A2 - test JAL\n");

    # Address for test results
    la      x1, test_A2_res

        li      x2, 0x77777777
        jal    x0, 1f+2 
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4

    RVMODEL_IO_WRITE_STR(x30, "# Test part A2  - Complete\n");

    RVMODEL_IO_WRITE_STR(x30, "# Test part B1 - test BEQ\n");

    la      x1, test_B1_res

        # Register initialization
        li      x5, 5
        li      x6, 5

        # Test
        li      x2, 0x99999999
        beq     x5, x6, 1f + 2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4
    
    RVMODEL_IO_WRITE_STR(x30, "# Test part B1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x30, "# Test part B2 - test BNE\n");

    # Address for test results
    la      x1, test_B2_res

    # Register initialization
    li      x5, 5
    li      x6, 6

    # Test
    li      x2, 0x88888888
        bne     x5, x6, 1f + 2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4
    RVMODEL_IO_WRITE_STR(x30, "# Test part B2  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x30, "# Test part B3 - test BLT\n");

    # Address for test results
    la      x1, test_B3_res
    
    
    # Register initialization
    li      x5, 5
    li      x6, 6

    # Test
    li      x2, 0xAAAAAAAA
        blt     x5, x6, 1f + 2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4
    RVMODEL_IO_WRITE_STR(x30, "# Test part B3 - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x30, "# Test part B4 - test BLTU\n");

    # Address for test results
    la      x1, test_B4_res

    # Register initialization
    li      x5, 5
    li      x6, 6

    # Test
    li      x2, 0xBBBBBBBB
        bltu     x5, x6, 1f + 2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4
    RVMODEL_IO_WRITE_STR(x30, "# Test part B4  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x30, "# Test part B5 - test BGE\n");

    # Address for test results
    la      x1, test_B5_res

    # Register initialization
    li      x5, 5
    li      x6, 6

    # Test
    li      x2, 0xCCCCCCCC
        bge     x6, x5, 1f + 2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4    
    
    RVMODEL_IO_WRITE_STR(x30, "# Test part B5  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x30, "# Test part B6 - test BGEU\n");

    # Address for test results
    la      x1, test_B6_res

    # Register initialization
    li      x5, 5
    li      x6, 6

    # Test
    li      x2, 0xDDDDDDDD
        bgeu     x6, x5, 1f + 2
        nop
        li      x2, 0
        sw      x2, 0(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 0(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 4    
    RVMODEL_IO_WRITE_STR(x30, "# Test part B6  - Complete\n");



    RVMODEL_IO_WRITE_STR(x30, "# Test End\n")

#endif
  
    # HALT

RVTEST_CODE_END

RVMODEL_HALT
RVTEST_DATA_BEGIN
# Input data section.
    .data
    .align 4
RVTEST_DATA_END


# Output data section.
RVMODEL_DATA_BEGIN
    .align 4

test_A1_res:
    .fill 5, 4, 0xdeaddead
test_A2_res:
    .fill 1, 4, 0xdeaddead
test_B1_res:
    .fill 1, 4, 0xdeaddead
test_B2_res:
    .fill 1, 4, 0xdeaddead
test_B3_res:
    .fill 1, 4, 0xdeaddead
test_B4_res:
    .fill 1, 4, 0xdeaddead
test_B5_res:
    .fill 1, 4, 0xdeaddead
test_B6_res:
    .fill 1, 4, 0xdeaddead 
mtrap_sigptr:
  .fill 64, 4, 0xdeaddead

RVMODEL_DATA_END
