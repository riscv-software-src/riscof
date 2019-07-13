# RISC-V Compliance Test I-LUI-01
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
# Description: Testing instruction LUI.

#include "compliance_test.h"
#include "compliance_model.h"


RVTEST_ISA("RV32I")

# Test Virtual Machine (TVM) used by program.


# Test code region
RVTEST_CODE_BEGIN

    RVMODEL_IO_INIT
    RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
    RVMODEL_IO_WRITE_STR(x31, "# Test Begin\n")

  #ifdef TEST_CASE_1
    RVTEST_CASE(1,"// check ISA:=regex(.*I.*); def TEST_CASE_1=True")
    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A - general test of LUI\n");

    # Address for test results
    RVTEST_SIGBASE(x15, test_A_res)

    # Test
    lui     x1, 0x0
    lui     x3, 0x1
    lui     x5, 0xFFFFF
    lui     x29, 0x7FFFF
    lui     x31, 0x80000

    # Store results
    RVMODEL_IO_CHECK()
    RVTEST_SIGUPD(x15, x1, 0x00000000)
    RVTEST_SIGUPD(x15, x3, 0x00001000)
    RVTEST_SIGUPD(x15, x5, 0xFFFFF000)
    RVTEST_SIGUPD(x15, x29, 0x7FFFF000)
    RVTEST_SIGUPD(x15, x31, 0x80000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part B - test LUI overwrites low bits\n");

    # Addresses for test data and results
    la      x15, test_B_data
    RVTEST_SIGBASE(x16, test_B_res)

    # Load testdata
    lw      x2, 0(x15)
    lw      x4, 0(x15)
    lw      x6, 0(x15)
    lw      x28, 0(x15)
    lw      x30, 0(x15)

    # Test
    lui     x2, 0x80000
    lui     x4, 0x7FFFF
    lui     x6, 0
    lui     x28, 1
    lui     x30, 0xFFFFF

    # Store results

    RVTEST_SIGUPD(x16, x2, 0x80000000)
    RVTEST_SIGUPD(x16, x4, 0x7FFFF000)
    RVTEST_SIGUPD(x16, x6, 0x00000000)
    RVTEST_SIGUPD(x16, x28, 0x00001000)
    RVTEST_SIGUPD(x16, x30, 0xFFFFF000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A2  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part C - test loading immediate using lui + addi or li alias\n");

    # Address for results
    RVTEST_SIGBASE(x17, test_C_res)

    # Test
    li      x1,  0x42726E6F
    li      x15, 0x12345678
    li      x30, 0x9ABCDEF0

    lui     x2, 0x42727
    addi    x2, x2, 0xFFFFFE6F
    lui     x16, 0x12345
    addi    x16, x16, 0x678
    lui     x31, 0x9ABCE
    addi    x31, x31, 0xFFFFFEF0

    # Store results

    RVTEST_SIGUPD(x17, x1,  0x42726E6F)
    RVTEST_SIGUPD(x17, x15, 0x12345678)
    RVTEST_SIGUPD(x17, x30, 0x9ABCDEF0)
    RVTEST_SIGUPD(x17, x2,  0x42726E6F)
    RVTEST_SIGUPD(x17, x16, 0x12345678)
    RVTEST_SIGUPD(x17, x31, 0x9ABCDEF0)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A3  - Complete\n");

    RVMODEL_IO_WRITE_STR(x31, "# Test End\n")
  #endif
 # ---------------------------------------------------------------------------------------------
    # HALT
    RVMODEL_HALT

RVTEST_CODE_END

# Input data section.
    .data
    .align 4

test_B_data:
    .word 0x11111111


# Output data section.
RVMODEL_DATA_BEGIN
    .align 4

test_A_res:
    .fill 5, 4, -1
test_B_res:
    .fill 5, 4, -1
test_C_res:
    .fill 6, 4, -1

RVMODEL_DATA_END
