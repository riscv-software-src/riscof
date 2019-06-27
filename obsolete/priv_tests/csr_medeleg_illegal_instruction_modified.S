
# This tests the delegation/no-delegation feature of the illegal_instruction_exception
# Do not execute test part 6 before other tests as it may change the working mode to S mode. 
# In general, tests should be conducted in order.

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"
#include "implementation.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

#define MISA_SUPERVISOR 18
#define MISA_USER 20
#define MISA_USER_TRAP 13

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")
    
    // Assert
    
    RVTEST_START

    la      s0 , test_res
    # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(1, "Check if reading medeleg causes illegal");
    RVTEST_PART_SKIP(1, "MISA_S: 1");
    RVTEST_PART_SKIP(1, "MISA_USER_TRAP: 1");

    # setting misa.S and reading it as 1
    li      t5, 1 << MISA_SUPERVISOR
    csrc    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    li      t2, 1
    beq     t5, t2, test_part_2 # skip if supervisor mode

    # setting misa.S and reading it as 1
    li      t5, 1 << MISA_USER
    csrc    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_USER
    andi    t5, t5, 1
    li      t2, 1
    beq     t5, t2, 1f

    li      t5, 1 << MISA_USER_TRAP
    csrc    misa, t5
    csrr    t5, misa
    srl     t5, t5, MISA_USER_TRAP
    andi    t5, t5, 1
    li      t2, 1
    beq     t5, t2, test_part_2

1:
    li      t2 , 0xff 
    csrr    t5 , medeleg # if this instruction causes exception, t2 value will be overwritten by exception handler.
    li      t3 , 0x3
    bne     t2 , t3 , test_end 

    RVTEST_PART_END(1)

    # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(2, "# medeleg[CAUSE_ILLEGAL_INSTRUCTION] should not be hardwired to 1 \n");
    RVTEST_PART_SKIP(2, "MISA_S: 0");

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_3 # skip if no supervisor mode
 
    li      t5, 1<<CAUSE_ILLEGAL_INSTRUCTION
    csrc    medeleg , t5
    csrr    t5, medeleg
    srl     t5, t5, CAUSE_ILLEGAL_INSTRUCTION
    andi    t5, t5, 1
    bnez    t5, test_end
   
    RVTEST_PART_END(2)

# ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(3, "# when medeleg.[CAUSE_ILLEGAL_INSTRUCTION]=0, exception should not be delegated to S mode");
    RVTEST_PART_SKIP(3, "MISA_S: 0");

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_4 # skip if no supervisor mode
 
    # resetting medeleg[CAUSE_ILLEGAL_INSTRUCTION]
    li      t5 , 1<<CAUSE_ILLEGAL_INSTRUCTION
    csrc    medeleg , t5

    li      s1 , 0xff 
    .word   0xFFFFFF3 # An illegal instruction to cause the exception and handler rewrites the s1
    li      s2 , 3 # The expected ID is loaded in S2 and cross checked with s1.
    bne     s1 , s2 , test_end # if the expected ID != s1, test fails

    RVTEST_PART_END(3)

# ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(4, "# when medeleg.[CAUSE_ILLEGAL_INSTRUCTION]=0, exception in S mode should not be delegated to S mode");
    RVTEST_PART_SKIP(4, "MISA_S: 0"); 

    # setting misa.S and reading it as 1
    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_5 # branch if no supervisor mode

    # Enter supervisor mode.
    la t0, 1f
    csrw mepc , t0
    li t0, MSTATUS_MPP
    csrc mstatus, t0
    li t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_S
    csrs mstatus, t5
    mret    
1:
    li      s1 , 0xff
    .word   0xFFFFFF3
    li      s2 , 3
    bne     s1 , s2 , test_end
     
    RVTEST_PART_END(4)

# ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(5, "# when medeleg.[CAUSE_ILLEGAL_INSTRUCTION]=1, exception in M mode should !delegated to S mode. \n");
    RVTEST_PART_SKIP(5, "MISA_S: 0");
    RVTEST_PART_SKIP(5, "MEDELEG_ILLEGAL_INSTRUCTION: 0"); 


    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_6 # skip if no supervisor mode

    # check if medeleg[CAUSE_ILLEGAL_INSTRUCTION] can be set, skip test otherwise
    li t5, 1 << CAUSE_ILLEGAL_INSTRUCTION
    csrs medeleg, t5
    csrr t5, medeleg
    srl t5, t5, CAUSE_ILLEGAL_INSTRUCTION
    andi t5, t5, 1
    beqz t5, test_part_6

    li      s1 , 0xff
    .word   0xFFFFFF3
    li      s2 , 3
    bne     s1 , s2 , test_end

    RVTEST_PART_END(5)    

    # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(6, "# when medeleg.[CAUSE_ILLEGAL_INSTRUCTION]=1, exception in S mode should be delegated to S mode. \n");
    RVTEST_PART_SKIP(6, "MISA_S: 0"); 
    RVTEST_PART_SKIP(6, "MEDELEG_ILLEGAL_INSTRUCTION: 0"); 

    # setting misa.S and reading it as 1
    li      t5 , 1 << MISA_SUPERVISOR 
    csrs    misa , t5
    csrr    t5 , misa
    srl     t5 , t5 , MISA_SUPERVISOR 
    andi    t5 , t5 , 1
    beqz    t5 , test_part_7 # branch if no supervisor mode
    
    # check if medeleg[CAUSE_ILLEGAL_INSTRUCTION] can be set, skip test otherwise
    li t5, 1 << CAUSE_ILLEGAL_INSTRUCTION
    csrs medeleg, t5
    csrr t5, medeleg
    srl t5, t5, CAUSE_ILLEGAL_INSTRUCTION
    andi t5, t5, 1
    beqz t5, test_part_7

    # Enter supervisor mode.
    la t0, 1f
    csrw mepc, t0
    li t0, MSTATUS_MPP
    csrc mstatus, t0
    li t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_S
    csrs mstatus, t5
    mret    
1:
    li      s1 , 0xff
    .word   0xFFFFFF3
    li      s2 , 1
    bne     s1 , s2 , test_end

    RVTEST_PART_END(6)

    # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(7, "# when medeleg.[CAUSE_ILLEGAL_INSTRUCTION]=1, exception in S mode should be delegated to S mode. \n");
    RVTEST_PART_SKIP(7, "MISA_S: 1"); 
    RVTEST_PART_SKIP(7, "MISA_U: 0"); 
    RVTEST_PART_SKIP(7, "MISA_USER_TRAP: 0"); 

    # setting misa.S and reading it as 1
    li      t5 , 1 << MISA_SUPERVISOR 
    csrc    misa , t5
    csrr    t5 , misa
    srl     t5 , t5 , MISA_SUPERVISOR 
    andi    t5 , t5 , 1
    bnez    t5 , test_end # skip if supervisor mode

    # setting misa.U 
    li      t5 , 1 << MISA_USER
    csrs    misa , t5
    csrr    t5 , misa
    srl     t5 , t5 , MISA_USER
    andi    t5 , t5 , 1
    beqz    t5 , test_end # skip if no user mode

    # setting misa.N user mode trap 
    li      t5 , 1 << MISA_USER_TRAP
    csrs    misa , t5
    csrr    t5 , misa
    srl     t5 , t5 , MISA_USER_TRAP
    andi    t5 , t5 , 1
    beqz    t5 , test_end # skip if no user mode trap

    # check if medeleg[CAUSE_ILLEGAL_INSTRUCTION] can be set, skip test otherwise
    li t5, 1 << CAUSE_ILLEGAL_INSTRUCTION
    csrs medeleg, t5
    csrr t5, medeleg
    srl t5, t5, CAUSE_ILLEGAL_INSTRUCTION
    andi t5, t5, 1
    beqz t5, test_end

    # Enter user mode.
    la t0, 1f
    csrw mepc, t0
    li t0, MSTATUS_MPP
    csrc mstatus, t0
    li t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_U
    csrs mstatus, t5
    mret    
1:
    li      s1 , 0xff
    .word   0xFFFFFF3
    li      s2 , 1
    bne     s1 , s2 , test_end

    RVTEST_PART_END(7)

    j       test_end

# machine mode trap handler & Returns to machine mode permanently  

mtvec_handler:

    # increment return address
    csrr    x30 , mepc
    #addi    x30 , x30 , 4
    lh      x31, (x30) # fetching instruction
    # check the lower 2 bits to see if the instruction is 32-bit or 16-bit.
    andi x31, x31, 0x3;
    li t3, 0x3
    bne x31,t3,inst16
inst32:                           # is 32-bit instruction then increment by 4
  addi x30,x30, 0x4
  j 1f
inst16:
  addi x30,x30, 0x2                  # is 16-bit instruction then increment by 2
1: 
  csrw mepc, x30                   # point mepc to the next instruction.

    csrw    mepc , x30    

    # Store MCAUSE
    csrr    t5 , mcause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    # Reformatting mstatus to keep in machine mode
    li      t5, MSTATUS_MPP
    csrs    mstatus , t5
   
    li      s1 , 3
    mret

#if SUPERVISOR != 0
# Supervisor exception handler

stvec_handler:

  # increment exception address
    csrr    x30, sepc
    addi    x30, x30, 4
    csrw    sepc, x30
    
    # Store SCAUSE
    csrr    t5 , scause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    li      s1 , 1
    sret
#endif

#if USER != 0
# Supervisor exception handler

utvec_handler:

  # increment exception address
    csrr    x30, CSR_UEPC
    addi    x30, x30, 4
    csrw    CSR_UEPC, x30
    
    # Store SCAUSE
    csrr    t5 , CSR_UCAUSE
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    li      s1 , 1
    uret
#endif

# --------------------------------------------------------------------------------------------- 
    # End test
    
test_end:
  
    RVTEST_IO_WRITE_STR("# Test End\n")

# ---------------------------------------------------------------------------------------------
    # HALT
    RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

# Input data section.
    .data
# Output data section.
RV_COMPLIANCE_DATA_BEGIN
test_res:
    .fill 6, 4, -1

RV_COMPLIANCE_DATA_END
