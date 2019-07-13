# RISC-V Compliance Test I-SLTI-01
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
# Description: Testing instruction SLTI.

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
    RVMODEL_IO_WRITE_STR(x31, "# Test part A1 - general test of value 0 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A1_data
    RVTEST_SIGBASE(x2, test_A1_res)

    # Load testdata
    lw      x3, 0(x1)

    # Test
    slti    x4, x3, 1
    slti    x5, x3, 0x7FF
    slti    x6, x3, 0xFFFFFFFF
    slti    x7, x3, 0
    slti    x8, x3, 0xFFFFF800

    # Store results
    RVMODEL_IO_CHECK()
    RVTEST_SIGUPD(x2, x3, 0x00000000)
    RVTEST_SIGUPD(x2, x4, 0x00000001)
    RVTEST_SIGUPD(x2, x5, 0x00000001)
    RVTEST_SIGUPD(x2, x6, 0x00000000)
    RVTEST_SIGUPD(x2, x7, 0x00000000)
    RVTEST_SIGUPD(x2, x8, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A2 - general test of value 1 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A2_data
    RVTEST_SIGBASE(x2, test_A2_res)

    # Load testdata
    lw      x8, 0(x1)

    # Test
    slti    x9, x8, 1
    slti    x10, x8, 0x7FF
    slti    x11, x8, 0xFFFFFFFF
    slti    x12, x8, 0
    slti    x13, x8, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x2, x8,  0x00000001)
    RVTEST_SIGUPD(x2, x9,  0x00000000)
    RVTEST_SIGUPD(x2, x10, 0x00000001)
    RVTEST_SIGUPD(x2, x11, 0x00000000)
    RVTEST_SIGUPD(x2, x12, 0x00000000)
    RVTEST_SIGUPD(x2, x13, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A2  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A3 - general test of value -1 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A3_data
    RVTEST_SIGBASE(x2, test_A3_res)

    # Load testdata
    lw      x13, 0(x1)

    # Test
    slti    x14, x13, 1
    slti    x15, x13, 0x7FF
    slti    x16, x13, 0xFFFFFFFF
    slti    x17, x13, 0
    slti    x18, x13, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x2, x13, 0xFFFFFFFF)
    RVTEST_SIGUPD(x2, x14, 0x00000001)
    RVTEST_SIGUPD(x2, x15, 0x00000001)
    RVTEST_SIGUPD(x2, x16, 0x00000000)
    RVTEST_SIGUPD(x2, x17, 0x00000001)
    RVTEST_SIGUPD(x2, x18, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A3  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A4 - general test of value 0x7FFFFFFF with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A4_data
    RVTEST_SIGBASE(x2, test_A4_res)

    # Load testdata
    lw      x18, 0(x1)

    # Test
    slti    x19, x18, 1
    slti    x20, x18, 0x7FF
    slti    x21, x18, 0xFFFFFFFF
    slti    x22, x18, 0
    slti    x23, x18, 0xFFFFF800

    # Store results
    RVTEST_SIGUPD(x2, x18, 0x7FFFFFFF)
    RVTEST_SIGUPD(x2, x19, 0x00000000)
    RVTEST_SIGUPD(x2, x20, 0x00000000)
    RVTEST_SIGUPD(x2, x21, 0x00000000)
    RVTEST_SIGUPD(x2, x22, 0x00000000)
    RVTEST_SIGUPD(x2, x23, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A4  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A5 - general test of value 0x80000000 with 0, 1, -1, MIN, MAX immediate values\n");

    # Addresses for test data and results
    la      x1, test_A5_data
    RVTEST_SIGBASE(x2, test_A5_res)

    # Load testdata
    lw      x23, 0(x1)

    # Test
    slti    x24, x23, 1
    slti    x25, x23, 0x7FF
    slti    x26, x23, 0xFFFFFFFF
    slti    x27, x23, 0
    slti    x28, x23, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x2, x23, 0x80000000)
    RVTEST_SIGUPD(x2, x24, 0x00000001)
    RVTEST_SIGUPD(x2, x25, 0x00000001)
    RVTEST_SIGUPD(x2, x26, 0x00000001)
    RVTEST_SIGUPD(x2, x27, 0x00000001)
    RVTEST_SIGUPD(x2, x28, 0x00000001)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A5  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part B - testing writing to x0\n");

    # Addresses for test data and results
    la      x26, test_B_data
    RVTEST_SIGBASE(x27, test_B_res)

    # Load testdata
    lw      x1, 0(x26)

    # Test
    slti    x0, x1, 1

    # Store results


    RVTEST_SIGUPD(x27, x1, 0xFFFFFFFF)
    RVTEST_SIGUPD(x27, x0, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part B  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part C - testing compare x0\n");

    # Addresses for test data and results
    RVTEST_SIGBASE(x31, test_C_res)

    # Test
    slti    x1, x0, 1
    slti    x2, x0, 0x7FF
    slti    x3, x0, 0xFFFFFFFF
    slti    x4, x0, 0
    slti    x5, x0, 0xFFFFF800

    # Store results

    RVTEST_SIGUPD(x31, x0, 0x00000000)
    RVTEST_SIGUPD(x31, x1, 0x00000001)
    RVTEST_SIGUPD(x31, x2, 0x00000001)
    RVTEST_SIGUPD(x31, x3, 0x00000000)
    RVTEST_SIGUPD(x31, x4, 0x00000000)
    RVTEST_SIGUPD(x31, x5, 0x00000000)

    RVMODEL_IO_WRITE_STR(x31, "# Test part C  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part D - testing forwarding between instructions\n");

    # Addresses for test data and results
    RVTEST_SIGBASE(x31, test_D_res)

    # Test
    slti    x1, x0, 1
    slti    x2, x1, 1
    slti    x28, x2, 1
    slti    x29, x28, 1
    slti    x30, x29, 1

    # Store results

    RVTEST_SIGUPD(x31, x0,  0x00000000)
    RVTEST_SIGUPD(x31, x1,  0x00000001)
    RVTEST_SIGUPD(x31, x2,  0x00000000)
    RVTEST_SIGUPD(x31, x28, 0x00000001)
    RVTEST_SIGUPD(x31, x29, 0x00000000)
    RVTEST_SIGUPD(x31, x30, 0x00000001)

    RVMODEL_IO_WRITE_STR(x31, "# Test part D  - Complete\n");

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
    .word 0xFFFFFFFF

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
    .fill 2, 4, -1
test_C_res:
    .fill 6, 4, -1
test_D_res:
    .fill 6, 4, -1


RVMODEL_DATA_END
