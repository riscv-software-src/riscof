# RISC-V Compliance Test RV32IMC-C.LWSP-01
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
# Specification: RV32IMC Base Integer Instruction Set, Version 2.0
# Description: Testing instruction C.LWSP.


#include "compliance_test.h"
#include "compliance_model.h"

RVTEST_ISA("RV32IC")



RVTEST_CODE_BEGIN

  RVMODEL_IO_INIT
  RVMODEL_IO_WRITE_STR(x31, "Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")
    #ifdef TEST_CASE_1
    RVTEST_CASE(1,"// check ISA:=regex(.*I.*); check ISA:=regex(.*C.*); def TEST_CASE_1=True")

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 1 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x1, test_1_res)

  la x2,test_data;
c.lwsp x4, 0(x2);
RVTEST_SIGUPD( x1,x4,0x11111111)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 2 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x1, test_2_res)

  la x2,test_data;
c.lwsp x8, 4(x2);
RVTEST_SIGUPD( x1,x8,0x22222222)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 3 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x1, test_3_res)

  la x2,test_data;
c.lwsp x16, 8(x2);
RVTEST_SIGUPD( x1,x16,0x33333333)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 4 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x1, test_4_res)

  la x2,test_data;
c.lwsp x21, 124(x2);
RVTEST_SIGUPD( x1,x21,0x44444444)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 5 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x1, test_5_res)

  la x2,test_data;
c.lwsp x21, 252(x2);
RVTEST_SIGUPD( x1,x21,0x55555555)

  RVMODEL_IO_WRITE_STR(x31, "Test End\n")

  # ---------------------------------------------------------------------------------------------

    #endif
  RVMODEL_HALT

RVTEST_CODE_END

# Input data section.
  .data
.align 4
test_data:
    .word 0x11111111
    .word 0x22222222
    .word 0x33333333
    .fill 28, 4, -1
    .word 0x44444444
    .fill 31, 4, -1
    .word 0x55555555

# Output data section.
RVMODEL_DATA_BEGIN
test_1_res:
  .fill 1, 4, -1
test_2_res:
  .fill 1, 4, -1
test_3_res:
  .fill 1, 4, -1
test_4_res:
  .fill 1, 4, -1
test_5_res:
  .fill 1, 4, -1

RVMODEL_DATA_END

