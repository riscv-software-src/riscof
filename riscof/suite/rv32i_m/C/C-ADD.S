# RISC-V Compliance Test RV32IMC-C.ADD-01
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
# Description: Testing instruction C.ADD.


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
    RVTEST_SIGBASE(  x2, test_1_res)

    li  x4, 0x0;
li  x3, 0x0;
c.add  x3, x4;
RVTEST_SIGUPD( x2, x3, 0x0)
    li  x9, 0x0;
li  x8, 0x1;
c.add  x8, x9;
RVTEST_SIGUPD( x2, x8, 0x1)
    li  x12, 0x0;
li  x11, -0x1;
c.add  x11, x12;
RVTEST_SIGUPD( x2, x11, 0xffffffff)
    li  x14, 0x0;
li  x13, 0x7fff;
c.add  x13, x14;
RVTEST_SIGUPD( x2, x13, 0x7fff)
    li  x16, 0x0;
li  x15, 0x8000;
c.add  x15, x16;
RVTEST_SIGUPD( x2, x15, 0x8000)

    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 2 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(  x2, test_2_res)

    li  x18, 0x1;
li  x17, 0x0;
c.add  x17, x18;
RVTEST_SIGUPD( x2, x17, 0x1)
    li  x20, 0x1;
li  x19, 0x1;
c.add  x19, x20;
RVTEST_SIGUPD( x2, x19, 0x2)
    li  x22, 0x1;
li  x21, -0x1;
c.add  x21, x22;
RVTEST_SIGUPD( x2, x21, 0x0)
    li  x24, 0x1;
li  x23, 0x7fff;
c.add  x23, x24;
RVTEST_SIGUPD( x2, x23, 0x8000)
    li  x26, 0x1;
li  x25, 0x8000;
c.add  x25, x26;
RVTEST_SIGUPD( x2, x25, 0x8001)

    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 3 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(  x2, test_3_res)

    li  x28, -0x1;
li  x27, 0x0;
c.add  x27, x28;
RVTEST_SIGUPD( x2, x27, 0xffffffff)
    li  x30, -0x1;
li  x29, 0x1;
c.add  x29, x30;
RVTEST_SIGUPD( x2, x29, 0x0)
    li  x3, -0x1;
li  x21, -0x1;
c.add  x21, x3;
RVTEST_SIGUPD( x2, x21, 0xfffffffe)
    li  x8, -0x1;
li  x4, 0x7fff;
c.add  x4, x8;
RVTEST_SIGUPD( x2, x4, 0x7ffe)
    li  x11, -0x1;
li  x9, 0x8000;
c.add  x9, x11;
RVTEST_SIGUPD( x2, x9, 0x7fff)

    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 4 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(  x2, test_4_res)

    li  x13, 0x7fff;
li  x12, 0x0;
c.add  x12, x13;
RVTEST_SIGUPD( x2, x12, 0x7fff)
    li  x15, 0x7fff;
li  x14, 0x1;
c.add  x14, x15;
RVTEST_SIGUPD( x2, x14, 0x8000)
    li  x17, 0x7fff;
li  x16, -0x1;
c.add  x16, x17;
RVTEST_SIGUPD( x2, x16, 0x7ffe)
    li  x19, 0x7fff;
li  x18, 0x7fff;
c.add  x18, x19;
RVTEST_SIGUPD( x2, x18, 0xfffe)
    li  x21, 0x7fff;
li  x20, 0x8000;
c.add  x20, x21;
RVTEST_SIGUPD( x2, x20, 0xffff)

    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 5 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(  x2, test_5_res)

    li  x23, 0x8000;
li  x22, 0x0;
c.add  x22, x23;
RVTEST_SIGUPD( x2, x22, 0x8000)
    li  x25, 0x8000;
li  x24, 0x1;
c.add  x24, x25;
RVTEST_SIGUPD( x2, x24, 0x8001)
    li  x27, 0x8000;
li  x26, -0x1;
c.add  x26, x27;
RVTEST_SIGUPD( x2, x26, 0x7fff)
    li  x29, 0x8000;
li  x28, 0x7fff;
c.add  x28, x29;
RVTEST_SIGUPD( x2, x28, 0xffff)
    li  x21, 0x8000;
li  x30, 0x8000;
c.add  x30, x21;
RVTEST_SIGUPD( x2, x30, 0x10000)

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
