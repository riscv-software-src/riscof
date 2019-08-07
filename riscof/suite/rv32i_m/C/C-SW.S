# RISC-V Compliance Test RV32IMC-C.SW-01
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
# Description: Testing instruction C.SW.


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

  li  x8, 0x0;
la  x12,test_data;
 c.sw  x8, 0( x12);
lw  x8, 0( x12);
RVTEST_SIGUPD( x2, x8, 0x0)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 2 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_2_res)

  li  x9, 0x1;
la  x15,test_data;
 c.sw  x9, 4( x15);
lw  x9, 4( x15);
RVTEST_SIGUPD( x2, x9, 0x1)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 3 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_3_res)

  li  x10, 0xffffffff;
la  x9,test_data;
 c.sw  x10, 8( x9);
lw  x10, 8( x9);
RVTEST_SIGUPD( x2, x10, 0xffffffff)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 4 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_4_res)

  li  x13, 0x7fff;
la  x14,test_data;
 c.sw  x13, 16( x14);
lw  x13, 16( x14);
RVTEST_SIGUPD( x2, x13, 0x7fff)

  # ---------------------------------------------------------------------------------------------

  RVMODEL_IO_WRITE_STR(x31, "# Test number 5 - corner cases\n")

  # address for test results
  RVTEST_SIGBASE(	x2, test_5_res)

  li  x15, 0x8000;
la  x12,test_data;
 c.sw  x15, 124( x12);
lw  x15, 124( x12);
RVTEST_SIGUPD( x2, x15, 0x8000)

  RVMODEL_IO_WRITE_STR(x31, "Test End\n")

  # ---------------------------------------------------------------------------------------------

    
    #endif
  RVMODEL_HALT

RVTEST_CODE_END

# Input data section.
  .data
test_data:
  .fill 32, 4, -1
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
