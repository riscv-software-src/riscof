# RISC-V Compliance Test RV32IMC-C.SUB-01
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
# Description: Testing instruction C.SUB.


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

  li  x11, 0x0;
li  x9, 0x0;
c.sub  x9, x11;
RVTEST_SIGUPD( x2, x9, 0x0)
  li  x13, 0x0;
li  x12, 0x1;
c.sub  x12, x13;
RVTEST_SIGUPD( x2, x12, 0x1)
  li  x15, 0x0;
li  x14, -0x1;
c.sub  x14, x15;
RVTEST_SIGUPD( x2, x14, 0xffffffff)
  li  x9, 0x0;
li  x8, 0x7fff;
c.sub  x8, x9;
RVTEST_SIGUPD( x2, x8, 0x7fff)
  li  x12, 0x0;
li  x11, 0x8000;
c.sub  x11, x12;
RVTEST_SIGUPD( x2, x11, 0x8000)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 2 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_2_res)

  li  x14, 0x1;
li  x13, 0x0;
c.sub  x13, x14;
RVTEST_SIGUPD( x2, x13, 0xffffffff)
  li  x8, 0x1;
li  x15, 0x1;
c.sub  x15, x8;
RVTEST_SIGUPD( x2, x15, 0x0)
  li  x11, 0x1;
li  x9, -0x1;
c.sub  x9, x11;
RVTEST_SIGUPD( x2, x9, 0xfffffffe)
  li  x13, 0x1;
li  x12, 0x7fff;
c.sub  x12, x13;
RVTEST_SIGUPD( x2, x12, 0x7ffe)
  li  x15, 0x1;
li  x14, 0x8000;
c.sub  x14, x15;
RVTEST_SIGUPD( x2, x14, 0x7fff)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 3 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_3_res)

  li  x9, -0x1;
li  x8, 0x0;
c.sub  x8, x9;
RVTEST_SIGUPD( x2, x8, 0x1)
  li  x12, -0x1;
li  x11, 0x1;
c.sub  x11, x12;
RVTEST_SIGUPD( x2, x11, 0x2)
  li  x14, -0x1;
li  x13, -0x1;
c.sub  x13, x14;
RVTEST_SIGUPD( x2, x13, 0x0)
  li  x8, -0x1;
li  x15, 0x7fff;
c.sub  x15, x8;
RVTEST_SIGUPD( x2, x15, 0x8000)
  li  x11, -0x1;
li  x9, 0x8000;
c.sub  x9, x11;
RVTEST_SIGUPD( x2, x9, 0x8001)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 4 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_4_res)

  li  x13, 0x7fff;
li  x12, 0x0;
c.sub  x12, x13;
RVTEST_SIGUPD( x2, x12, 0xffff8001)
  li  x15, 0x7fff;
li  x14, 0x1;
c.sub  x14, x15;
RVTEST_SIGUPD( x2, x14, 0xffff8002)
  li  x9, 0x7fff;
li  x8, -0x1;
c.sub  x8, x9;
RVTEST_SIGUPD( x2, x8, 0xffff8000)
  li  x12, 0x7fff;
li  x11, 0x7fff;
c.sub  x11, x12;
RVTEST_SIGUPD( x2, x11, 0x0)
  li  x14, 0x7fff;
li  x13, 0x8000;
c.sub  x13, x14;
RVTEST_SIGUPD( x2, x13, 0x1)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 5 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_5_res)

  li  x8, 0x8000;
li  x15, 0x0;
c.sub  x15, x8;
RVTEST_SIGUPD( x2, x15, 0xffff8000)
  li  x11, 0x8000;
li  x9, 0x1;
c.sub  x9, x11;
RVTEST_SIGUPD( x2, x9, 0xffff8001)
  li  x13, 0x8000;
li  x12, -0x1;
c.sub  x12, x13;
RVTEST_SIGUPD( x2, x12, 0xffff7fff)
  li  x15, 0x8000;
li  x14, 0x7fff;
c.sub  x14, x15;
RVTEST_SIGUPD( x2, x14, 0xffffffff)
  li  x9, 0x8000;
li  x8, 0x8000;
c.sub  x8, x9;
RVTEST_SIGUPD( x2, x8, 0x00)

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