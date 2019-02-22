# RISC-V Compliance Test RV32IM-REM-01
#
# Copyright (c) 2018, Imperas Software Ltd.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#      * Neither the name of the Imperas Software Ltd. nor the
#        names of its contributors may be used to endorse or promote products
#        derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Imperas Software Ltd. BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Specification: RV32IM Base Integer Instruction Set, Version 2.0
# Description: Testing instruction REM.

#include "test_macros.h"
#include "compliance_test.h"
#include "compliance_io.h"

RV_COMPLIANCE_RV32M

RV_COMPLIANCE_CODE_BEGIN

	RVTEST_IO_INIT
	RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
	RVTEST_IO_WRITE_STR("Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
  RVTEST_START

	# ---------------------------------------------------------------------------------------------

	RVTEST_IO_WRITE_STR("# Test number 1 - corner cases\n")

  #ifdef TEST_PART_1
    RVTEST_PART_START(1, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x17, x18, 0, 0x0, 0x0, x2, 0)
    RVTEST_PART_END(1)
  #endif
  #ifdef TEST_PART_2
    RVTEST_PART_START(2, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x19, x20, 0, 0x0, 0x1, x2, 4)
    RVTEST_PART_END(2)
  #endif
  #ifdef TEST_PART_3
    RVTEST_PART_START(3, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x21, x22, 0, 0x0, -0x1, x2, 8)
    RVTEST_PART_END(3)
  #endif
  #ifdef TEST_PART_4
    RVTEST_PART_START(4, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x23, x24, 0, 0x0, 0x7fffffff, x2, 12)
    RVTEST_PART_END(4)
  #endif
  #ifdef TEST_PART_5
    RVTEST_PART_START(5, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x25, x26, 0, 0x0, 0x80000000, x2, 16)
    RVTEST_PART_END(5)
  #endif

	# ---------------------------------------------------------------------------------------------

	RVTEST_IO_WRITE_STR("# Test number 2 - corner cases\n")

  #ifdef TEST_PART_6
    RVTEST_PART_START(6, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x27, x28, 0x1, 0x1, 0x0, x2, 0)
    RVTEST_PART_END(6)
  #endif
  #ifdef TEST_PART_7
    RVTEST_PART_START(7, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x29, x30, 0, 0x1, 0x1, x2, 4)
    RVTEST_PART_END(7)
  #endif
  #ifdef TEST_PART_8
    RVTEST_PART_START(8, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x31, x3, 0, 0x1, -0x1, x2, 8)
    RVTEST_PART_END(8)
  #endif
  #ifdef TEST_PART_9
    RVTEST_PART_START(9, "# Corner Case -1")
	    TEST_RR_SRC2(rem, x4, x8, 0x1, 0x1, 0x7fffffff, x2, 12)
    RVTEST_PART_END(9)
  #endif
  #ifdef TEST_PART_10
    RVTEST_PART_START(10, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x9, x11, 0x1, 0x1, 0x80000000, x2, 16)
    RVTEST_PART_END(10)
  #endif

	# ---------------------------------------------------------------------------------------------

	RVTEST_IO_WRITE_STR("# Test number 3 - corner cases\n")

  #ifdef TEST_PART_11
    RVTEST_PART_START(11, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x12, x13, 0xffffffff, -0x1, 0x0, x2, 0)
    RVTEST_PART_END(11)
  #endif
  #ifdef TEST_PART_12
    RVTEST_PART_START(12, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x14, x15, 0, -0x1, 0x1, x2, 4)
    RVTEST_PART_END(12)
  #endif
  #ifdef TEST_PART_13
    RVTEST_PART_START(13, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x16, x17, 0, -0x1, -0x1, x2, 8)
    RVTEST_PART_END(13)
  #endif
  #ifdef TEST_PART_14
    RVTEST_PART_START(14, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x18, x19, 0xffffffff, -0x1, 0x7fffffff, x2, 12)
    RVTEST_PART_END(14)
  #endif
  #ifdef TEST_PART_15
    RVTEST_PART_START(15, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x20, x21, 0xffffffff, -0x1, 0x80000000, x2, 16)
    RVTEST_PART_END(15)
  #endif

	# ---------------------------------------------------------------------------------------------

	RVTEST_IO_WRITE_STR("# Test number 4 - corner cases\n")

  #ifdef TEST_PART_16
    RVTEST_PART_START(16, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x22, x23, 0x7fffffff, 0x7fffffff, 0x0, x2, 0)
    RVTEST_PART_END(16)
  #endif
  #ifdef TEST_PART_17
    RVTEST_PART_START(17, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x24, x25, 0, 0x7fffffff, 0x1, x2, 4)
    RVTEST_PART_END(17)
  #endif
  #ifdef TEST_PART_18
    RVTEST_PART_START(18, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x26, x27, 0, 0x7fffffff, -0x1, x2, 8)
    RVTEST_PART_END(18)
  #endif
  #ifdef TEST_PART_19
    RVTEST_PART_START(19, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x28, x29, 0, 0x7fffffff, 0x7fffffff, x2, 12)
    RVTEST_PART_END(19)
  #endif
  #ifdef TEST_PART_20
    RVTEST_PART_START(20, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x30, x31, 0x7fffffff, 0x7fffffff, 0x80000000, x2, 16)
    RVTEST_PART_END(20)
  #endif

	# ---------------------------------------------------------------------------------------------

	RVTEST_IO_WRITE_STR("# Test number 5 - corner cases\n")

  #ifdef TEST_PART_21
    RVTEST_PART_START(21, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x3, x4, 0x80000000, 0x80000000, 0x0, x2, 0)
    RVTEST_PART_END(21)
  #endif
  #ifdef TEST_PART_22
    RVTEST_PART_START(22, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x8, x9, 0, 0x80000000, 0x1, x2, 4)
    RVTEST_PART_END(22)
  #endif
  #ifdef TEST_PART_23
    RVTEST_PART_START(23, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x11, x12, 0, 0x80000000, -0x1, x2, 8)
    RVTEST_PART_END(23)
  #endif
  #ifdef TEST_PART_24
    RVTEST_PART_START(24, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x13, x14, 0xffffffff, 0x80000000, 0x7fffffff, x2, 12)
    RVTEST_PART_END(24)
  #endif
  #ifdef TEST_PART_25
    RVTEST_PART_START(25, "# Corner Case 0")
	    TEST_RR_SRC2(rem, x15, x16, 0, 0x80000000, 0x80000000, x2, 16)
    RVTEST_PART_END(25)
  #endif

	RVTEST_IO_WRITE_STR("Test End\n")

	# ---------------------------------------------------------------------------------------------
test_end:
	RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

# Input data section.
	.data

# Output data section.
RV_COMPLIANCE_DATA_BEGIN
test_res:
	.fill 4, 4, -1
	.fill 4, 4, -1
	.fill 4, 4, -1
	.fill 4, 4, -1
	.fill 4, 4, -1
	.fill 4, 4, -1
	.fill 1, 4, -1

RV_COMPLIANCE_DATA_END
