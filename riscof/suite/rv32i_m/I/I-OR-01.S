# RISC-V Compliance Test I-OR-01
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
# Description: Testing instruction OR.

#include "compliance_test.h"
#include "compliance_model.h"


RVTEST_ISA("RV32I")

# Test Virtual Machine (TVM) used by program.


# Test code region.
RVTEST_CODE_BEGIN

    RVMODEL_IO_INIT
    RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
    RVMODEL_IO_WRITE_STR(x31, "# Test Begin\n")

  #ifdef TEST_CASE_1
    RVTEST_CASE(1,"// check ISA:=regex(.*I.*); def TEST_CASE_1=True")
    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A1 - general test of value 0 with 0, 1, -1, MIN, MAX register values\n");

    # Addresses for test data and results
    la      x1, test_A1_data
    RVTEST_SIGBASE(x2, test_A1_res)

    # Load testdata
    lw      x3, 0(x1)

    # Register initialization
    li      x4, 0
    li      x5, 1
    li      x6, -1
    li      x7, 0x7FFFFFFF
    li      x8, 0x80000000

    # Test
    or      x4, x3, x4
    or      x5, x3, x5
    or      x6, x3, x6
    or      x7, x3, x7
    or      x8, x3, x8

    # Store results
    RVMODEL_IO_CHECK()
    RVTEST_SIGUPD(x2, x3, 0x00000000)
    RVTEST_SIGUPD(x2, x4, 0x00000000)
    RVTEST_SIGUPD(x2, x5, 0x00000001)
    RVTEST_SIGUPD(x2, x6, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x7, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x8, 0x80000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A2 - general test of value 1 with 0, 1, -1, MIN, MAX register values\n");

    # Addresses for test data and results
    la      x1, test_A2_data
    RVTEST_SIGBASE(x2, test_A2_res)

    # Load testdata
    lw      x8, 0(x1)

    # Register initialization
    li      x9, 0
    li      x10, 1
    li      x11, -1
    li      x12, 0x7FFFFFFF
    li      x13, 0x80000000

    # Test
    or      x9, x8, x9
    or      x10, x8, x10
    or      x11, x8, x11
    or      x12, x8, x12
    or      x13, x8, x13

    # Store results
    RVTEST_SIGUPD(x2, x8,  0x00000001)
    RVTEST_SIGUPD(x2, x9,  0x00000001)
    RVTEST_SIGUPD(x2, x10, 0x00000001)
    RVTEST_SIGUPD(x2, x11, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x12, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x13, 0x80000001)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A2  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A3 - general test of value -1 with 0, 1, -1, MIN, MAX register values\n");

    # Addresses for test data and results
    la      x1, test_A3_data
    RVTEST_SIGBASE(x2, test_A3_res)

    # Load testdata
    lw      x13, 0(x1)

    # Register initialization
    li      x14, 0
    li      x15, 1
    li      x16, -1
    li      x17, 0x7FFFFFFF
    li      x18, 0x80000000

    # Test
    or      x14, x13, x14
    or      x15, x13, x15
    or      x16, x13, x16
    or      x17, x13, x17
    or      x18, x13, x18

    # Store results

    RVTEST_SIGUPD(x2, x13, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x14, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x15, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x16, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x17, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x18, 0xFFFFFFFF)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A3  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A4 - general test of value 0x7FFFFFFF with 0, 1, -1, MIN, MAX register values\n");

    # Addresses for test data and results
    la      x1, test_A4_data
    RVTEST_SIGBASE(x2, test_A4_res)

    # Load testdata
    lw      x18, 0(x1)

    # Register initialization
    li      x19, 0
    li      x20, 1
    li      x21, -1
    li      x22, 0x7FFFFFFF
    li      x23, 0x80000000

    # Test execution
    or      x19, x18, x19
    or      x20, x18, x20
    or      x21, x18, x21
    or      x22, x18, x22
    or      x23, x18, x23

    # Store results

    RVTEST_SIGUPD(x2, x18, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x19, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x20, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x21, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x22, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x23, 0xFFFFFFFF)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A4  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A5 - general test of value 0x80000000 with 0, 1, -1, MIN, MAX register values\n");

    # Addresses for test data and results
    la      x1, test_A5_data
    RVTEST_SIGBASE(x2, test_A5_res)

    # Load testdata
    lw      x23, 0(x1)

    # Register initialization
    li      x24, 0
    li      x25, 1
    li      x26, -1
    li      x27, 0x7FFFFFFF
    li      x28, 0x80000000

    # Test
    or      x24, x23, x24
    or      x25, x23, x25
    or      x26, x23, x26
    or      x27, x23, x27
    or      x28, x23, x28

    # Store results

    RVTEST_SIGUPD(x2, x23, 0x80000000)
    RVTEST_SIGUPD(x2, x24, 0x80000000)
    RVTEST_SIGUPD(x2, x25, 0x80000001)
    RVTEST_SIGUPD(x2, x26, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x27, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x28, 0x80000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A5  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part B - testing forwarding between instructions\n");

    # Addresses for test data and results
    la      x25, test_B_data
    RVTEST_SIGBASE(x26, test_B_res)

    # Load testdata
    lw      x28, 0(x25)

    # Register initialization
    li      x4, 0x10
    li      x5, 0x20
    li      x6, 0x40
    li      x7, 0x80
    li      x8, 0x100
    li      x9, 0xFFFFF800

    # Test
    or      x29, x28, x4
    or      x30, x29, x5
    or      x31, x30, x6
    or      x1, x31, x7
    or      x2, x1, x8
    or      x3, x2, x9

    # store results

    RVTEST_SIGUPD(x26, x4,  0x00000010)
    RVTEST_SIGUPD(x26, x28, 0x0000000D)
    RVTEST_SIGUPD(x26, x29, 0x0000001D)
    RVTEST_SIGUPD(x26, x30, 0x0000003D)
    RVTEST_SIGUPD(x26, x31, 0x0000007D)
    RVTEST_SIGUPD(x26, x1,  0x000000FD)
    RVTEST_SIGUPD(x26, x2,  0x000001FD)
    RVTEST_SIGUPD(x26, x3,  0xFFFFF9FD)

    RVMODEL_IO_WRITE_STR(x31, "# Test part B  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part C - testing writing to x0\n");

    # Addresses for test data and results
    la      x1, test_C_data
    RVTEST_SIGBASE(x2, test_C_res)

    # Load testdata
    lw      x28, 0(x1)

    # Register initialization
    li      x27, 0xF7FF8818

    # Test
    or      x0, x28, x27

    # store results

    RVTEST_SIGUPD(x2, x0, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part C  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part D - testing forwarding throught x0\n");

    # Addresses for test data and results
    la      x1, test_D_data
    RVTEST_SIGBASE(x2, test_D_res)

    # Load testdata
    lw      x28, 0(x1)

    # Register initialization
    li      x27, 0xF7FF8818

    # Test
    or      x0, x28, x27
    or      x5, x0, x0

    # store results


    RVTEST_SIGUPD(x2, x0, 0x00000000)
    RVTEST_SIGUPD(x2, x5, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part D  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part E - testing moving (or with x0)\n");

    # Addresses for test data and results
    la      x1, test_E_data
    RVTEST_SIGBASE(x2, test_E_res)

    # Load testdata
    lw      x3, 0(x1)

    # Test
    or      x4, x3, x0
    or      x5, x4, x0
    or      x6, x0, x5
    or      x14, x6, x0
    or      x15, x14, x0
    or      x16, x15, x0
    or      x25, x0, x16
    or      x26, x0, x25
    or      x27, x26, x0

    # Store results

    RVTEST_SIGUPD(x2, x4, 0x36925814)
    RVTEST_SIGUPD(x2, x26, 0x36925814)
    RVTEST_SIGUPD(x2, x27, 0x36925814)

    RVMODEL_IO_WRITE_STR(x31, "# Test part E  - Complete\n");

    RVMODEL_IO_WRITE_STR(x31, "# Test End\n")
  #endif
 # ---------------------------------------------------------------------------------------------
    # HALT
    RVMODEL_HALT

RVTEST_CODE_END

# Input data section.
    .data
    .align 4

test_A1_data:
    .word 0
test_A2_data:
    .word 1
test_A3_data:
    .word -1
test_A4_data:
    .word 0x7FFFFFFF
test_A5_data:
    .word 0x80000000
test_B_data:
    .word 0x0000000D
test_C_data:
    .word 0x12345678
test_D_data:
    .word 0xFEDCBA98
test_E_data:
    .word 0x36925814

# Output data section.
RVMODEL_DATA_BEGIN
    .align 4

test_A1_res:
    .fill 6, 4, -1
test_A2_res:
    .fill 6, 4, -1
test_A3_res:
    .fill 6, 4, -1
test_A4_res:
    .fill 6, 4, -1
test_A5_res:
    .fill 6, 4, -1
test_B_res:
    .fill 8, 4, -1
test_C_res:
    .fill 1, 4, -1
test_D_res:
    .fill 2, 4, -1
test_E_res:
    .fill 3, 4, -1

RVMODEL_DATA_END     # End of test output data region.
