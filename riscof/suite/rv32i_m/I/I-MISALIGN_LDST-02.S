# RISC-V Compliance Test I-MISALIGN_LDST-01
#
# Copyright (c) 2017, Codasip Ltd.
# Copyright (c) 2018, Imperas Software Ltd. Additions
# Copyright (c) 2018, InCore Semiconductors Pvt. Ltd. 
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#      * Neither the name of the Codasip Ltd., Imperas Software Ltd., 
#        InCore Semiconductor Pvt. Ltd. nor the
#        names of its contributors may be used to endorse or promote products
#        derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Codasip Ltd., Imperas Software Ltd.,
# InCore Semiconductors Pvt. Ltd. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Specification: RV32I Base Integer Instruction Set, Version 2.0
# Description: Testing MISALIGNED LOAD/STORE exception. This test implements a simple handler for
# various mis-aligned data exceptions. For implementation which support mis-aligned access in HW 
# the trap handler is never invoked.

#include "compliance_test.h"
#include "compliance_model.h"


RVTEST_ISA("RV32I")

# Test Virtual Machine (TVM) used by program.


# Test code region
RVTEST_CODE_BEGIN

    RVMODEL_IO_INIT
    RVMODEL_IO_ASSERT_GPR_EQ(x31,x0, 0x00000000)
    RVMODEL_IO_WRITE_STR(x31,"# Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
  #ifdef TEST_CASE_1
    RVTEST_CASE(1,"check ISA:=regex(.*I.*); def TEST_CASE_1=True")
    # Save and set trap handler address
    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31,"# Test part A1 - test LW\n");

    # set trap handler to handle LW misaligned in software
    la x1, lw_trap_handler
    csrrw x31, mtvec, x1

    # Addresses for test data and results
    la      x3, test_data
    RVTEST_SIGBASE(x2, test_A1_res)

    # Test - mis-aligned by 1 byte
    li      x4,  0
    addi    x3,  x3,  0x1
    lw      x4, 0(x3)
    RVTEST_SIGUPD(x2, x4, 0xbaabcdef)

    # Test - mis-aligned by 2 bytes
    addi    x3,  x3,  0x1
    li      x4,  0
    lw      x4, 0(x3)
    RVTEST_SIGUPD(x2, x4, 0xdcbaabcd)

    # Test - mis-aligned by 3 bytes
    addi    x3,  x3,  0x1
    li      x4,  0
    lw      x4, 0(x3)
    RVTEST_SIGUPD(x2, x4, 0xfedcbaab)

    RVMODEL_IO_WRITE_STR(x31,"# Test part A1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31,"# Test part A2 - test LH\n");

    # set trap handler to handle LH misaligned in software
    la x1, lh_trap_handler
    csrw mtvec, x1

    # Addresses for test data and results
    la      x3, test_data
    RVTEST_SIGBASE(x2, test_A2_res)

    # Test - mis-aligned by 1 byte
    addi    x3,  x3,  0x1
    li      x4,  0
    lh      x4, 0(x3)
    RVTEST_SIGUPD(x2, x4, 0xffffcdef)

    # Test - mis-aligned by 3 byte
    addi    x3,  x3,  0x2
    li      x4,  0
    lh      x4, 0(x3)
    RVTEST_SIGUPD(x2, x4, 0xffffbaab)

    RVMODEL_IO_WRITE_STR(x31,"# Test part A2  - Complete\n");
    
    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31,"# Test part A3 - test LHU\n");
    
    # set trap handler to handle LHU misaligned in software
    la x1, lhu_trap_handler
    csrw mtvec, x1

    # Addresses for test data and results
    la      x3, test_data
    RVTEST_SIGBASE(x2, test_A3_res)

    # Test - mis-aligned by 1 byte
    addi    x3,  x3,  0x1
    li      x4,  0
    lhu     x4, 0(x3)
    RVTEST_SIGUPD(x2, x4, 0xcdef)

    # Test - mis-aligned by 3 byte
    addi    x3,  x3,  0x2
    li      x4,  0
    lhu     x4, 0(x3)
    RVTEST_SIGUPD(x2, x4, 0xbaab)

    RVMODEL_IO_WRITE_STR(x31,"# Test part A3  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31,"# Test part B1 - test SW\n");

    la x1, sw_trap_handler
    csrw mtvec, x1

    # Addresses for test data and results
    la      x1, test_data1
    RVTEST_SIGBASE(x2, test_B1_res)

    # Register initialization
    li      x6, 0x0
    li      x5, 0x99999999

    # Init memory
    sw      x5, 0(x1)
    sw      x5, 4(x1)
    sw      x5, 8(x1)
    sw      x5, 12(x1)
    sw      x5, 16(x1)

    # Test
    addi    x1, x1, 0x5
    sw      x6, 0(x1)
    
    addi    x1, x1, 0x5
    sw      x6, 0(x1)

    addi    x1, x1, 0x5
    sw      x6, 0(x1)

    la      x1, test_data1
    lw      x5, 0(x1)
    RVTEST_SIGUPD(x2, x5, 0x99999999)

    lw      x5, 4(x1)
    RVTEST_SIGUPD(x2, x5, 0x00000099)

    lw      x5, 8(x1)
    RVTEST_SIGUPD(x2, x5, 0x00009900)

    lw      x5, 12(x1)
    RVTEST_SIGUPD(x2, x5, 0x00990000)

    lw      x5, 16(x1)
    RVTEST_SIGUPD(x2, x5, 0x99000000)

    RVMODEL_IO_WRITE_STR(x31,"# Test part B1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31,"# Test part B2 - test SH\n");

    la x1, sh_trap_handler
    csrw mtvec, x1

    # Addresses for test data and results
    la      x1, test_data2
    RVTEST_SIGBASE(x2, test_B2_res)
    
    # Register initialization
    li      x6, 0x0
    li      x5, 0x99999999

    # Init memory
    sw      x5, 0(x1)
    sw      x5, 4(x1)
    sw      x5, 8(x1)
    sw      x5, 12(x1)
    sw      x5, 16(x1)

    # Test
    addi    x1, x1, 0x5
    sh      x6, 0(x1)

    addi    x1, x1, 0xA
    sh      x6, 0(x1)

    la      x1, test_data2
    lw      x5, 0(x1)
    RVTEST_SIGUPD(x2, x5, 0x99999999)

    lw      x5, 4(x1)
    RVTEST_SIGUPD(x2, x5, 0x99000099)

    lw      x5, 8(x1)
    RVTEST_SIGUPD(x2, x5, 0x99999999)

    lw      x5, 12(x1)
    RVTEST_SIGUPD(x2, x5, 0x00999999)

    lw      x5, 16(x1)
    RVTEST_SIGUPD(x2, x5, 0x99999900)

    RVMODEL_IO_WRITE_STR(x31,"# Test part B2  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    # restore mtvec and jump to the end
    csrw mtvec, x31
    jal x0, test_end

    # ---------------------------------------------------------------------------------------------
    # Exception handler
lw_trap_handler:

    bnez x4, test_end
    # load fourth byte
    lb x5, 3(x3)
    slli x5, x5, 24
    or x4, x4, x5

    # load third byte
    lbu x5, 2(x3)
    slli x5, x5, 16
    or x4, x4, x5

lhu_trap_handler:    
    # load second byte
    lbu x5, 1(x3)
    slli x5, x5, 8
    or x4, x4, x5

    # load first byte
    lbu x5, 0(x3)
    or x4, x4, x5
    j exit_handler
    
lh_trap_handler:    
    # load second byte
    lb x5, 1(x3)
    slli x5, x5, 8
    or x4, x4, x5

    # load first byte
    lbu x5, 0(x3)
    or x4, x4, x5
    j exit_handler

sw_trap_handler:
    sb x0, 3(x1)
    sb x0, 2(x1)

sh_trap_handler:
    sb x0, 1(x1)
    sb x0, 0(x1)

exit_handler:
    # increment return address
    csrr    x30, mepc
    addi    x30, x30, 4
    csrw    mepc, x30
    # return
    mret
    

    # ---------------------------------------------------------------------------------------------

test_end:

    RVMODEL_IO_WRITE_STR(x31,"# Test End\n")
  #endif
 # ---------------------------------------------------------------------------------------------
    # HALT
    RVMODEL_HALT

RVTEST_CODE_END

# Input data section.
    .data
    .align 4

test_data:
    .word 0xABCDEF89
    .word 0x98FEDCBA

test_data1:
    .word 0xdead1
    .word 0xdead2
    .word 0xdead3
    .word 0xdead4
    .word 0xdead5

test_data2:
    .word 0xbeaf1
    .word 0xbeaf2
    .word 0xbeaf3
    .word 0xbeaf4
    .word 0xbeaf5

# Output data section.
RVMODEL_DATA_BEGIN
    .align 4

test_A1_res:
    .fill 3, 4, -1
test_A2_res:
    .fill 2, 4, -1
test_A3_res:
    .fill 2, 4, -1
test_B1_res:
    .fill 5, 4, -1
test_B2_res:
    .fill 5, 4, -1

RVMODEL_DATA_END
