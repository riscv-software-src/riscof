# Run this test after ebreak_exception test (Dependency).
# Tests if mepc == exception causing instruction in M mode 
# In general, tests should be conducted in order.

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"
#include "implementation.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

#define MISA_SUPERVISOR 18
#define MISA_USER 20

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")

    // Initialize part number and signature address    
    RVTEST_START

    csrr x4, mtvec
    la t5, mtvec_handler
    csrw mtvec, t5

    csrwi medeleg, 0

    // Spec: When a trap is taken into M-mode, mepc is written with the 
    // virtual address of the instruction that was interrupted or that encountered 
    // the exception.
    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(1, "# Check mepc on illegal exception")

    li s1, 0xff
illegal_addr1:
    .word 0xffffff3
    li s2, 0x3dead
    bne s1, s2, test_end

    RVTEST_PART_END(1)

   // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(2, "# mepc update on supervisor exception not delegated")
    RVTEST_PART_SKIP(2, "MISA_S: 0")

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_3 // skip if no supervisor mode
 
    // resetting medeleg[CAUSE_ILLEGAL_INSTRUCTION]
    li      t5 , 1<<CAUSE_ILLEGAL_INSTRUCTION
    csrc    medeleg , t5

    // Enter supervisor mode.
    la t0, 1f
    csrw mepc, t0
    li t0, MSTATUS_MPP
    csrc mstatus, t0
    li t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_S
    csrs mstatus, t5
    mret    
1:
    li      s1 , 0xff 
illegal_addr2:
    .word   0xFFFFFF3 
    li      s2 , 0x3dead 
    bne     s1 , s2 , test_end 

    RVTEST_PART_END(2)

    // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(3, "# mepc not updated on exception delegation")
    RVTEST_PART_SKIP(3, "MISA_S: 0")
    RVTEST_PART_SKIP(3, "MEDELEG_ILLEGAL_INSTRUCTION: 0"); 

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_4
 
    // setting medeleg[CAUSE_ILLEGAL_INSTRUCTION]
    li      t5 , 1<<CAUSE_ILLEGAL_INSTRUCTION
    csrs    medeleg , t5
    csrr t5, medeleg
    srl t5, t5, CAUSE_ILLEGAL_INSTRUCTION
    andi t5, t5, 1
    beqz t5, test_part_4

    // Enter supervisor mode.
    la t0, 1f
    csrw mepc, t0
    li t0, MSTATUS_MPP
    csrc mstatus, t0
    li t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_S
    csrs mstatus, t5
    mret    
1:
    li      s1 , 0xff 
illegal_addr3:
    .word   0xFFFFFF3
    li      s2 , 0x1dead 
    bne     s1 , s2 , test_end 

    ecall
    RVTEST_PART_END(3)

   // ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(4, "# mepc update on user exception not delegated")
    RVTEST_PART_SKIP(4, "MISA_S: 1")
    RVTEST_PART_SKIP(4, "MISA_U: 0") 

   // Clear MISA_S
    li      t5 , 1 << MISA_SUPERVISOR 
    csrc    misa , t5
    csrr    t5 , misa
    srl     t5 , t5 , MISA_SUPERVISOR 
    andi    t5 , t5 , 1
    bnez    t5 , test_end
  
    // Set MISA_U
    li      t5, 1 << MISA_USER
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_USER
    andi    t5, t5, 1
    beqz    t5, test_end
 
    // resetting medeleg[CAUSE_ILLEGAL_INSTRUCTION]
    li      t5 , 1<<CAUSE_ILLEGAL_INSTRUCTION
    csrc    medeleg , t5

    // Enter user mode.
    la t0, 1f
    csrw mepc, t0
    li t0, MSTATUS_MPP
    csrc mstatus, t0
    li t5, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_U
    csrs mstatus, t5
    mret    
1:
    li      s1 , 0xff 
illegal_addr4:
    .word   0xFFFFFF3 
    li      s2 , 0x3dead 
    bne     s1 , s2, test_end 

    RVTEST_PART_END(4)



    # ---------------------------------------------------------------------------------------------   
    j       test_end

.align 2
mtvec_handler:

    // increment return address
    csrr x30, mepc
    csrr x31, mcause
    li t2, 2
    bne t2, x31, 3f 
    li t2, 1
    bne t2, gp, 1f
    la t2, illegal_addr1
    bne t2, x30, test_end
    j increment
1: 
    li t2, 2
    bne t2, gp, 2f
    la t2, illegal_addr2
    bne t2, x30, test_end
    j increment
2: 
    li t2, 3
    beq t2, gp, test_end
    
    li t2, 4
    bne t2, gp, test_end
    la t2, illegal_addr4
    bne t2, x30, test_end
    j increment
3:
   // Store MCAUSE
    csrr    t5 , mcause
    li      t2 , CAUSE_SUPERVISOR_ECALL
    beq     t5, t2, increment
    li      t2 , CAUSE_USER_ECALL
    beq     t5, t2, increment
    j       test_end
 increment:
    addi    x30 , x30 , 4

    // point mepc to the next instruction.
    csrw    mepc , x30    

1:
    // Reformatting mstatus to keep in machine mode
    li      t5, MSTATUS_MPP
    csrs    mstatus , t5
   
    li      s1 , 0x3dead
    mret

#if SUPERVISOR != 0
// Supervisor exception handler
.align 2
stvec_handler:
    li t2, 3
    bne t2, gp, test_end

  // increment exception address
    csrr    x30, sepc
    la t2, illegal_addr3
    bne t2, x30, test_end
    addi    x30, x30, 4
    csrw    sepc, x30
    
    // Store SCAUSE
    csrr    t5 , scause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    li      s1 , 0x1dead
    sret
#endif

#if USER != 0
// user exception handler

.align 2
utvec_handler:

  // increment exception address
    csrr    x30, CSR_UEPC
    addi    x30, x30, 4
    csrw    CSR_UEPC, x30
    
    // Store SCAUSE
    csrr    t5 , CSR_UCAUSE
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5, t2, test_end

    li      s1 , 0x0dead
    uret
#endif

// --------------------------------------------------------------------------------------------- 
// End test
    
test_end:
    csrw mtvec, x4
    RVTEST_IO_WRITE_STR("# Test End\n")

# ---------------------------------------------------------------------------------------------
    # HALT
    RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

# Input data section.
    .data
    .align 4

# Output data section.
RV_COMPLIANCE_DATA_BEGIN
    .align 4

test_res:
    .fill 4, 4, -1

RV_COMPLIANCE_DATA_END
