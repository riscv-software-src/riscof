# This tests the delegation/no-delegation feature of the load_access_fault
# Do not execute test part 6 before other tests as it may change the working mode to S mode. 
# In general, tests should be conducted in order.
# s0,s1,s2,s3 are in use

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

#define MISA_SUPERVISOR 18
#define NON_ACCESSIBLE_MEMORY 0x1000000
#define LOAD_RESTRICTED_MEMORY 0x1000000

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
    RVTEST_PART_SKIP(1, "MISA_S_WARL_fn: [WARL_fn, 0]");

    # setting misa.S and reading it as 1
    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    li      t2, 1
    bne     t5, t2, test_part_2 # skip if no supervisor mode
  
    li      t5, 1 << MISA_SUPERVISOR
    csrc    misa , t5

    li      t2 , 0xff 
    csrr    t5 , medeleg # if this instruction causes exception, t2 value will be overwritten by exception handler.
    li      t3 , 0xff
    bne     t2 , t3 , test_end 

    RVTEST_PART_END(1)

# ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(2, "# medeleg[CAUSE_LOAD_ACCESS] should not be hardwired to 1 \n");
    RVTEST_PART_SKIP(2, "MISA_S_WARL_fn: [WARL_fn, 0]");

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_3 # skip if no supervisor mode
   
    li      t5, 1<<CAUSE_LOAD_ACCESS
    csrc    medeleg , t5
    csrr    t5, medeleg
    srl     t5, t5, CAUSE_LOAD_ACCESS
    andi    t5, t5, 1
    bnez    t5, test_end 
   
    RVTEST_PART_END(2)

# ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(3, "# when medeleg.[CAUSE_LOAD_ACCESS]=0, exception should not be delegated to S mode");
    RVTEST_PART_SKIP(3, "MISA_S_WARL_fn: [WARL_fn, 0]");

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_4 # skip if no supervisor mode
    
    # resetting medeleg[CAUSE_LOAD_ACCESS]
    li      t5 , 1<<CAUSE_LOAD_ACCESS
    csrc    medeleg , t5

    li     s1 , 0xff 
    li     t2 , LOAD_RESTRICTED_MEMORY # load access fault (use some load restricted memory adddress)
    lw     t5 , 0(t2)
    li      s2 , 3 # The expected ID is loaded in S2 and cross checked with s1.
    bne     s1 , s2 , test_end # if s2 != s1 (expected s1 = 3), test fails. 

    RVTEST_PART_END(3)

# ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(4, "# when medeleg.[CAUSE_LOAD_ACCESS]=0, exception in S mode should not be delegated to S mode");
    RVTEST_PART_SKIP(4, "MISA_S_WARL_fn: [WARL_fn, 0]"); 

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
    li     t2,LOAD_RESTRICTED_MEMORY # load access fault (use some load restricted memory adddress)
    lw     t5,0(t2)
    li      s2 , 3
    bne     s1 , s2 , test_end  # if s2 != s1 (expected s1 = 3), test fails. 

    RVTEST_PART_END(4)

# ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(5, "# when medeleg.[CAUSE_LOAD_ACCESS]=1, exception in M mode should !delegated to S mode. \n");
    RVTEST_PART_SKIP(5, "MISA_S_WARL_fn: [WARL_fn, 0]");
    RVTEST_PART_SKIP(5, "MEDELEG_LOAD_ACCESS_WARL_fn,[WARL_fn, 0]"); 

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_6 # skip if no supervisor mode
    
    # check if medeleg[CAUSE_LOAD_ACCESS] can be set, skip test otherwise
    li t5, 1 << CAUSE_LOAD_ACCESS
    csrs medeleg, t5
    csrr t5, medeleg
    srl t5, t5, CAUSE_LOAD_ACCESS
    andi t5, t5, 1
    beqz t5, test_part_6

    li      s1 , 0xff
    li     t2,LOAD_RESTRICTED_MEMORY # load access fault (use some load restricted memory adddress)
    lw     t5,0(t2)
    li      s2 , 3
    bne     s1 , s2 , test_end  # if s2 != s1 (expected s1 = 3), test fails.     

    RVTEST_PART_END(5)    

    # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(6, "# when medeleg.[CAUSE_LOAD_ACCESS]=1, exception in S mode should be delegated to S mode. \n");
    RVTEST_PART_SKIP(6, "MISA_S_WARL_fn: [WARL_fn, 0]"); 
    RVTEST_PART_SKIP(6, "MEDELEG_LOAD_ACCESS_WARL_fn: [WARL_fn, 0]"); 

    # setting misa.S and reading it as 1
    li      t5 , 1 << MISA_SUPERVISOR 
    csrs    misa , t5
    csrr    t5 , misa
    srl     t5 , t5 , MISA_SUPERVISOR 
    andi    t5 , t5 , 1
    beqz    t5 , test_end # branch if no supervisor mode
    
    # check if medeleg[CAUSE_LOAD_ACCESS] can be set, skip test otherwise
    li t5, 1 << CAUSE_LOAD_ACCESS
    csrs medeleg, t5
    csrr t5, medeleg
    srl t5, t5, CAUSE_LOAD_ACCESS
    andi t5, t5, 1
    beqz t5, test_end

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
    li     t2,LOAD_RESTRICTED_MEMORY # load access fault (use some load restricted memory adddress)
    lw     t5,0(t2)
    li      s2 , 1
    bne     s1 , s2 , test_end  # if s2 != s1 (expected s1 = 1), test fails.  

    RVTEST_PART_END(6) 

# ---------------------------------------------------------------------------------------------   

    j       test_end

# machine mode trap handler & Returns to machine mode permanently  

mtvec_handler:

    # increment return address
    csrr    x30 , mepc
    addi    x30 , x30 , 4
    csrw    mepc , x30    

    # Store MCAUSE
    csrr    t5 , mcause
    li      t2 , CAUSE_LOAD_ACCESS
    bne     t5, t2, test_end
    
    # Reformatting mstatus to keep in machine mode
    li      t5, MSTATUS_MPP
    csrs    mstatus , t5
   
    li      s1 , 3
    mret

# Supervisor exception handler

stvec_handler:
    # increment return address
    csrr    x30 , sepc
    addi    x30 , x30 , 4
    csrw    sepc , x30    

    # Store SCAUSE
    csrr    t5 , scause
    li      t2 , CAUSE_LOAD_ACCESS
    bne     t5, t2, test_end

    li      s1 , 1
    sret

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
    .align 4

# Output data section.
RV_COMPLIANCE_DATA_BEGIN
    .align 4

test_res:
    .fill 8, 4, -1

RV_COMPLIANCE_DATA_END
