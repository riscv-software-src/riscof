# RISC-V Compliance Test I-MISALIGN_JMP-01
#
# Copyright (c) 2017, Codasip Ltd.
# Copyright (c) 2018, Imperas Software Ltd. Additions
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
  RVTEST_CASE(1,"// check ISA:=regex(.*32.*); check ISA:=regex(.*I.*C.*Zicsr.*); check misa>rv32>extensions>type=warl; check writable(2,misa>rv32>extensions)=True; def TEST_CASE_1=True;def rvtest_mtrap_routine=True;")
    
    la x1, test_A0_res
    la t1,test_data
    csrr t4,0x301
    sw t4,0(t1)
    sw t4,0(x1)
        # Test
        la      x1, test_A0_res
        li      x2, 0x22222222
        la      x4, 1f
        addi    x4,x4,2
        jalr    x0, x4, 0
        li      x2, 0
        sw      x2, 4(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 4(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 8
        csrrci   x0, misa, 4
    csrr t4,0x301
    sw t4,0(x1)
        # Test
        li      x2, 0x33333333
        la      x4, 1f
        addi    x4,x4,2
        jalr    x0, x4, 0
        li      x2, 0
        sw      x2, 4(x1)
        jal     x0, 2f 
    1:
        .fill 1,2 ,0x00
        sw      x2, 4(x1)
        jal     x0, 2f 
        .fill 1,2 ,0x00
    2:
        addi    x1, x1, 8
   
    lw t4, 0(t1)
    csrw 0x301,t4
    RVMODEL_IO_WRITE_STR(x30, "# Test End\n")

#endif

RVTEST_CODE_END

RVMODEL_HALT
RVTEST_DATA_BEGIN
# Input data section.
    .data
    .align 4
    test_data:
        .word 0x00
RVTEST_DATA_END

# Output data section.
RVMODEL_DATA_BEGIN
    .align 4
test_A0_res:
    .fill 4, 4, 0xdeaddead 
mtrap_sigptr:                       /* mscratch points here */
  .fill 8, 4, 0xdeaddead


RVMODEL_DATA_END
