# RISC-V Compliance Test RV32IM-MULH-01
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
# Description: Testing instruction MULH.


#include "compliance_test.h"
#include "compliance_model.h"

RVTEST_ISA("RV32IM")



RVTEST_CODE_BEGIN

  RVMODEL_IO_INIT
  RVMODEL_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
  RVMODEL_IO_WRITE_STR(x31, "Test Begin Reserved regs ra(x1) a0(x10) t0(x5)\n")

  # ---------------------------------------------------------------------------------------------
  #ifdef TEST_CASE_1
    RVTEST_CASE(1,"// check ISA:=regex(.*I.*); check ISA:=regex(.*M.*); def TEST_CASE_1=True")
    RVMODEL_IO_WRITE_STR(x31, "# Test number 1 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(x2, test_1_res)

    li  x18, MASK_XLEN( 0x0)
    li  x17, MASK_XLEN( 0x0)
    mulh  x17,  x18,  x17
    
    RVTEST_SIGUPD( x2, x17,0x00000000)

    li  x20, MASK_XLEN( 0x0)
    li  x19, MASK_XLEN( 0x1)
    mulh  x19,  x20,  x19
    
    RVTEST_SIGUPD( x2, x19,0x00000000)

    li  x22, MASK_XLEN( 0x0)
    li  x21, MASK_XLEN( -0x1)
    mulh  x21,  x22,  x21
    
    RVTEST_SIGUPD( x2, x21,0x00000000)

    li  x24, MASK_XLEN( 0x0)
    li  x23, MASK_XLEN( 0x7fffffff)
    mulh  x23,  x24,  x23
    
    RVTEST_SIGUPD( x2, x23,0x00000000)

    li  x26, MASK_XLEN( 0x0)
    li  x25, MASK_XLEN( 0x80000000)
    mulh  x25,  x26,  x25
    
    RVTEST_SIGUPD( x2, x25,0x00000000)


    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 2 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(x2, test_2_res)

    li  x28, MASK_XLEN( 0x1)
    li  x27, MASK_XLEN( 0x0)
    mulh  x27,  x28,  x27
    
    RVTEST_SIGUPD( x2, x27,0x00000000)

    li  x30, MASK_XLEN( 0x1)
    li  x29, MASK_XLEN( 0x1)
    mulh  x29,  x30,  x29
    
    RVTEST_SIGUPD( x2, x29,0x00000000)

    li  x3, MASK_XLEN( 0x1)
    li  x21, MASK_XLEN( -0x1)
    mulh  x21,  x3,  x21
    
    RVTEST_SIGUPD( x2, x21,0xffffffff)

    li  x8, MASK_XLEN( 0x1)
    li  x4, MASK_XLEN( 0x7fffffff)
    mulh  x4,  x8,  x4
    
    RVTEST_SIGUPD( x2, x4,0x00000000)

    li  x11, MASK_XLEN( 0x1)
    li  x9, MASK_XLEN( 0x80000000)
    mulh  x9,  x11,  x9
    
    RVTEST_SIGUPD( x2, x9,0xffffffff)


    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 3 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(x2, test_3_res)

    li  x13, MASK_XLEN( -0x1)
    li  x12, MASK_XLEN( 0x0)
    mulh  x12,  x13,  x12
    
    RVTEST_SIGUPD( x2, x12,0x00000000)

    li  x15, MASK_XLEN( -0x1)
    li  x14, MASK_XLEN( 0x1)
    mulh  x14,  x15,  x14
    
    RVTEST_SIGUPD( x2, x14,0xffffffff)

    li  x17, MASK_XLEN( -0x1)
    li  x16, MASK_XLEN( -0x1)
    mulh  x16,  x17,  x16
    
    RVTEST_SIGUPD( x2, x16,0x00000000)

    li  x19, MASK_XLEN( -0x1)
    li  x18, MASK_XLEN( 0x7fffffff)
    mulh  x18,  x19,  x18
    
    RVTEST_SIGUPD( x2, x18,0xffffffff)

    li  x21, MASK_XLEN( -0x1)
    li  x20, MASK_XLEN( 0x80000000)
    mulh  x20,  x21,  x20
    
    RVTEST_SIGUPD( x2, x20,0x00000000)


    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 4 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(x2, test_4_res)

    li  x23, MASK_XLEN( 0x7fffffff)
    li  x22, MASK_XLEN( 0x0)
    mulh  x22,  x23,  x22
    
    RVTEST_SIGUPD( x2, x22,0x00000000)

    li  x25, MASK_XLEN( 0x7fffffff)
    li  x24, MASK_XLEN( 0x1)
    mulh  x24,  x25,  x24
    
    RVTEST_SIGUPD( x2, x24,0x00000000)

    li  x27, MASK_XLEN( 0x7fffffff)
    li  x26, MASK_XLEN( -0x1)
    mulh  x26,  x27,  x26
    
    RVTEST_SIGUPD( x2, x26,0xffffffff)

    li  x29, MASK_XLEN( 0x7fffffff)
    li  x28, MASK_XLEN( 0x7fffffff)
    mulh  x28,  x29,  x28
    
    RVTEST_SIGUPD( x2, x28,0x3fffffff)

    li  x21, MASK_XLEN( 0x7fffffff)
    li  x30, MASK_XLEN( 0x80000000)
    mulh  x30,  x21,  x30
    
    RVTEST_SIGUPD( x2, x30,0xc0000000)


    # ---------------------------------------------------------------------------------------------

    RVMODEL_IO_WRITE_STR(x31, "# Test number 5 - corner cases\n")

    # address for test results
    RVTEST_SIGBASE(x2, test_5_res)

    li  x4, MASK_XLEN( 0x80000000)
    li  x3, MASK_XLEN( 0x0)
    mulh  x3,  x4,  x3
    
    RVTEST_SIGUPD( x2, x3,0x00000000)

    li  x9, MASK_XLEN( 0x80000000)
    li  x8, MASK_XLEN( 0x1)
    mulh  x8,  x9,  x8
    
    RVTEST_SIGUPD( x2, x8,0xffffffff)

    li  x12, MASK_XLEN( 0x80000000)
    li  x11, MASK_XLEN( -0x1)
    mulh  x11,  x12,  x11
    
    RVTEST_SIGUPD( x2, x11,0x00000000)

    li  x14, MASK_XLEN( 0x80000000)
    li  x13, MASK_XLEN( 0x7fffffff)
    mulh  x13,  x14,  x13
    
    RVTEST_SIGUPD( x2, x13,0xc0000000)

    li  x16, MASK_XLEN( 0x80000000)
    li  x15, MASK_XLEN( 0x80000000)
    mulh  x15,  x16,  x15
    
    RVTEST_SIGUPD( x2, x15,0x40000000)


    RVMODEL_IO_WRITE_STR(x31, "Test End\n")
  #endif

  # ---------------------------------------------------------------------------------------------

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
