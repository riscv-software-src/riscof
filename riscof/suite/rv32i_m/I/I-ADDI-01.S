# RISC-V Compliance Test I-ADDI-01
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
# Description: Testing instruction ADDI.

#include "compliance_test.h"
#include "compliance_model.h"

RVTEST_ISA("RV32I")

# Test Virtual Machine (TVM) used by program.


# Test code region
RVTEST_CODE_BEGIN

    RVMODEL_IO_INIT
    RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
    RVMODEL_IO_WRITE_STR(x31, "# Test Begin\n")

    # ---------------------------------------------------------------------------------------------
  #ifdef TEST_CASE_1
    RVTEST_CASE(1,"// check ISA:=regex(.*I.*); def TEST_CASE_1=True")
    RVMODEL_IO_WRITE_STR(x31, "# Test part A1 - general test of value 0 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A1_data
    RVTEST_SIGBASE(x2, test_A1_res)

    # Load testdata
    lw      x3, 0(x1)

    # Test
    addi    x4, x3, 1
    addi    x5, x3, 0x7FF
    addi    x6, x3, 0xFFFFFFFF
    addi    x7, x3, 0
    addi    x8, x3, 0xFFFFF800

    # Store results

    RVMODEL_IO_CHECK()
    RVTEST_SIGUPD(x2, x3, 0x00000000)
    RVTEST_SIGUPD(x2, x4, 0x00000001)
    RVTEST_SIGUPD(x2, x5, 0x000007FF)
    RVTEST_SIGUPD(x2, x6, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x7, 0x00000000)
    RVTEST_SIGUPD(x2, x8, 0xFFFFF800)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A2 - general test of value 1 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A2_data
    RVTEST_SIGBASE(x2, test_A2_res)

    # Load testdata
    lw      x8, 0(x1)

    # Test
    addi    x9, x8, 1
    addi    x10, x8, 0x7FF
    addi    x11, x8, 0xFFFFFFFF
    addi    x12, x8, 0
    addi    x13, x8, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x2, x8,  0x00000001)
    RVTEST_SIGUPD(x2, x9,  0x00000002)
    RVTEST_SIGUPD(x2, x10, 0x00000800)
    RVTEST_SIGUPD(x2, x11, 0x00000000)
    RVTEST_SIGUPD(x2, x12, 0x00000001)
    RVTEST_SIGUPD(x2, x13, 0xFFFFF801)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A2  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A3 - general test of value -1 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A3_data
    RVTEST_SIGBASE(x2, test_A3_res)
    # Load testdata
    lw      x13, 0(x1)

    # Test
    addi    x14, x13, 1
    addi    x15, x13, 0x7FF
    addi    x16, x13, 0xFFFFFFFF
    addi    x17, x13, 0
    addi    x18, x13, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x2, x13, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x14, 0x00000000)
    RVTEST_SIGUPD(x2, x15, 0x000007FE)
    RVTEST_SIGUPD(x2, x16, 0xFFFFFFFE)
    RVTEST_SIGUPD(x2, x17, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x18, 0xFFFFF7FF)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A3  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A4 - general test of value 0x7FFFFFFF with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A4_data
    RVTEST_SIGBASE( x2, test_A4_res)

    # Load testdata
    lw      x18, 0(x1)

    # Test
    addi    x19, x18, 1
    addi    x20, x18, 0x7FF
    addi    x21, x18, 0xFFFFFFFF
    addi    x22, x18, 0
    addi    x23, x18, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x2, x18, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x19, 0x80000000)
    RVTEST_SIGUPD(x2, x20, 0x800007FE)
    RVTEST_SIGUPD(x2, x21, 0x7FFFFFFE)
    RVTEST_SIGUPD(x2, x22, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x23, 0x7FFFF7FF)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A4  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A5 - general test of value 0x80000000 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A5_data
    RVTEST_SIGBASE(x2, test_A5_res)

    # Load testdata
    lw      x23, 0(x1)

    # Test
    addi    x24, x23, 1
    addi    x25, x23, 0x7FF
    addi    x26, x23, 0xFFFFFFFF
    addi    x27, x23, 0
    addi    x28, x23, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x2, x23, 0x80000000)
    RVTEST_SIGUPD(x2, x24, 0x80000001)
    RVTEST_SIGUPD(x2, x25, 0x800007FF)
    RVTEST_SIGUPD(x2, x26, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x27, 0x80000000)
    RVTEST_SIGUPD(x2, x28, 0x7FFFF800)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A5  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part B - testing forwarding between instructions\n");

    # Addresses for test data and results
    la      x26, test_B_data
    RVTEST_SIGBASE(x27, test_B_res)

    # Load testdata
    lw      x28, 0(x26)

    # Test
    addi    x29, x28, 1
    addi    x30, x29, 1
    addi    x31, x30, 1
    addi    x1, x31, 1
    addi    x2, x1, 1
    addi    x3, x2, 1

    # Store results

    RVTEST_SIGUPD(x27, x28, 0x0000ABCD)
    RVTEST_SIGUPD(x27, x29, 0x0000ABCE)
    RVTEST_SIGUPD(x27, x30, 0x0000ABCF)
    RVTEST_SIGUPD(x27, x31, 0x0000ABD0)
    RVTEST_SIGUPD(x27, x1,  0x0000ABD1)
    RVTEST_SIGUPD(x27, x2,  0x0000ABD2)
    RVTEST_SIGUPD(x27, x3,  0x0000ABD3)

    RVMODEL_IO_WRITE_STR(x31, "# Test part B  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part C - testing writing to x0\n");

    # Addresses for test data and results
    la      x1, test_C_data
    RVTEST_SIGBASE(x2, test_C_res)

    # Load testdata
    lw      x5, 0(x1)

    # Test
    addi    x0, x5, 1

    # Store results

    RVTEST_SIGUPD(x2, x0, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part C  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part D - testing forwarding throught x0\n");

    # Addresses for test data and results
    la      x1, test_D_data
    RVTEST_SIGBASE(x2, test_D_res)

    # Load testdata
    lw      x5, 0(x1)

    # Test
    addi    x0, x5, 1
    addi    x5, x0, 1

    # Store results

    RVTEST_SIGUPD(x2, x0, 0x00000000)
    RVTEST_SIGUPD(x2, x5, 0x00000001)

    RVMODEL_IO_WRITE_STR(x31, "# Test part D  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part E - testing moving (addi with 0)\n");

    # Addresses for test data and results
    la      x1, test_E_data
    RVTEST_SIGBASE(x2, test_E_res)

    # Load testdata
    lw      x3, 0(x1)

    # Test
    addi    x4, x3, 0
    addi    x5, x4, 0
    addi    x6, x5, 0
    addi    x14, x6, 0
    addi    x15, x14, 0
    addi    x16, x15, 0
    addi    x25, x16, 0
    addi    x26, x25, 0
    addi    x27, x26, 0

    # Store results

    RVTEST_SIGUPD(x2, x3, 0x36925814)
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
    .word 0x0000ABCD
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
    .fill 7, 4, -1
test_C_res:
    .fill 1, 4, -1
test_D_res:
    .fill 2, 4, -1
test_E_res:
    .fill 4, 4, -1

RVMODEL_DATA_END
