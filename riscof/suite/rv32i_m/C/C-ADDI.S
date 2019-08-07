# RISC-V Compliance Test RV32IMC-C.ADDI-01
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
# Description: Testing instruction C.ADDI.


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
  RVTEST_SIGBASE(	x2, test_1_res)

  li  x3, 0x0;
c.addi  x3, 0x1;
RVTEST_SIGUPD( x2, x3, 0x1)
  li  x4, 0x0;
c.addi  x4, 0x2;
RVTEST_SIGUPD( x2, x4, 0x2)
  li  x8, 0x0;
c.addi  x8, 0xf;
RVTEST_SIGUPD( x2, x8, 0xf)
  li  x9, 0x0;
c.addi  x9, 0x10;
RVTEST_SIGUPD( x2, x9, 0x10)
  li  x11, 0x0;
c.addi  x11, 0x1f;
RVTEST_SIGUPD( x2, x11, 0x1f)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 2 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_2_res)

  li  x12, 0x1;
c.addi  x12, 0x1;
RVTEST_SIGUPD( x2, x12, 0x2)
  li  x13, 0x1;
c.addi  x13, 0x2;
RVTEST_SIGUPD( x2, x13, 0x3)
  li  x14, 0x1;
c.addi  x14, 0xf;
RVTEST_SIGUPD( x2, x14, 0x10)
  li  x15, 0x1;
c.addi  x15, 0x10;
RVTEST_SIGUPD( x2, x15, 0x11)
  li  x16, 0x1;
c.addi  x16, 0x1f;
RVTEST_SIGUPD( x2, x16, 0x20)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 3 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_3_res)

  li  x17, -0x1;
c.addi  x17, 0x1;
RVTEST_SIGUPD( x2, x17, 0x00)
  li  x18, -0x1;
c.addi  x18, 0x2;
RVTEST_SIGUPD( x2, x18, 0x1)
  li  x19, -0x1;
c.addi  x19, 0xf;
RVTEST_SIGUPD( x2, x19, 0xe)
  li  x20, -0x1;
c.addi  x20, 0x10;
RVTEST_SIGUPD( x2, x20, 0xf)
  li  x21, -0x1;
c.addi  x21, 0x1f;
RVTEST_SIGUPD( x2, x21, 0x1e)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 4 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_4_res)

  li  x22, 0x7ffff;
c.addi  x22, 0x1;
RVTEST_SIGUPD( x2, x22, 0x80000)
  li  x23, 0x7ffff;
c.addi  x23, 0x2;
RVTEST_SIGUPD( x2, x23, 0x80001)
  li  x24, 0x7ffff;
c.addi  x24, 0xf;
RVTEST_SIGUPD( x2, x24, 0x8000e)
  li  x25, 0x7ffff;
c.addi  x25, 0x10;
RVTEST_SIGUPD( x2, x25, 0x8000f)
  li  x26, 0x7ffff;
c.addi  x26, 0x1f;
RVTEST_SIGUPD( x2, x26, 0x8001e)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 5 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_5_res)

  li  x27, 0x80000;
c.addi  x27, 0x1;
RVTEST_SIGUPD( x2, x27, 0x80001)
  li  x28, 0x80000;
c.addi  x28, 0x2;
RVTEST_SIGUPD( x2, x28, 0x80002)
  li  x29, 0x80000;
c.addi  x29, 0xf;
RVTEST_SIGUPD( x2, x29, 0x8000f)
  li  x30, 0x80000;
c.addi  x30, 0x10;
RVTEST_SIGUPD( x2, x30, 0x80010)
  li  x21, 0x80000;
c.addi  x21, 0x1f;
RVTEST_SIGUPD( x2, x21, 0x8001f)

  RVMODEL_IO_WRITE_STR(x31, "Test End\n")

  # ---------------------------------------------------------------------------------------------

    
    #endif
  RVMODEL_HALT

RVTEST_CODE_END

# Input data section.
  .data

# Output data section.
RVMODEL_DATA_BEGIN
test_1_res:
  .fill 5, 4, -1
test_2_res:
  .fill 5, 4, -1
test_3_res:
  .fill 5, 4, -1
test_4_res:
  .fill 5, 4, -1
test_5_res:
  .fill 5, 4, -1

RVMODEL_DATA_END
