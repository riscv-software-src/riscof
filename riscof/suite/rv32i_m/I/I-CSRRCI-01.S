# RISC-V Compliance Test I-CSRRCI-01
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
# Description: Testing instruction CSRRCI.

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
    RVMODEL_IO_WRITE_STR(x31, "# Test part A1 - general test of csrrci\n");

    # Address for test results
    RVTEST_SIGBASE(x15, test_A1_res)

    # Register initialization
    li      x8, -1
    csrrw   x0, mscratch, x8

    # Test
    csrrci  x1, mscratch, 1
    csrrw   x1, mscratch, x8

    csrrci  x2, mscratch, 0
    csrrw   x2, mscratch, x8

    csrrci  x3, mscratch, 0x1F
    csrrw   x3, mscratch, x8

    csrrci  x4, mscratch, 0x10
    csrrw   x4, mscratch, x8

    csrrci  x5, mscratch, 0xF
    csrrw   x5, mscratch, x8


    # Store results
    RVMODEL_IO_CHECK()
    RVTEST_SIGUPD(x15, x0, 0x00000000)
    RVTEST_SIGUPD(x15, x1, 0xFFFFFFFE)
    RVTEST_SIGUPD(x15, x2, 0xFFFFFFFF)
    RVTEST_SIGUPD(x15, x3, 0xFFFFFFE0)
    RVTEST_SIGUPD(x15, x4, 0xFFFFFFEF)
    RVTEST_SIGUPD(x15, x5, 0xFFFFFFF0)
    RVTEST_SIGUPD(x15, x8, 0xFFFFFFFF)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A1  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part A2 - general test of csrrci\n");

    # Address for test results
    RVTEST_SIGBASE(x5, test_A2_res)

    # Register initialization
    li      x8, -1
    csrrw   x0, mscratch, x8

    # Test
    csrrci  x11, mscratch, 1
    csrrci  x12, mscratch, 0
    csrrci  x13, mscratch, 0x1F
    csrrci  x14, mscratch, 0x10
    csrrci  x15, mscratch, 0xF
    csrrci  x16, mscratch, 0


    # Store results

    RVTEST_SIGUPD(x5, x11, 0xFFFFFFFF)
    RVTEST_SIGUPD(x5, x12, 0xFFFFFFFE)
    RVTEST_SIGUPD(x5, x13, 0xFFFFFFFE)
    RVTEST_SIGUPD(x5, x14, 0xFFFFFFE0)
    RVTEST_SIGUPD(x5, x15, 0xFFFFFFE0)
    RVTEST_SIGUPD(x5, x16, 0xFFFFFFE0)
    RVTEST_SIGUPD(x5, x8, 0xFFFFFFFF)

    RVMODEL_IO_WRITE_STR(x31, "# Test part A2  - Complete\n");

    # ---------------------------------------------------------------------------------------------
    RVMODEL_IO_WRITE_STR(x31, "# Test part B - testing writing to x0\n");

    # Address for test results
    RVTEST_SIGBASE(x1, test_B_res)

    # Register initialization
    li      x20, 0x32165498
    csrrw   x0, mscratch, x20

    # Test
    csrrci   x0, mscratch, 0xF
    csrrw    x20, mscratch, x20


    # store results

    RVTEST_SIGUPD(x1, x0, 0x00000000)
    RVTEST_SIGUPD(x1, x20, 0x32165490)

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


# Output data section.
RVMODEL_DATA_BEGIN
    .align 4

test_A1_res:
    .fill 7, 4, -1
test_A2_res:
    .fill 7, 4, -1
test_B_res:
    .fill 2, 4, -1

RVMODEL_DATA_END     # End of test output data region.
