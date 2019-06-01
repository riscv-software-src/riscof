# Run this test after illegal_instruction_exception test (Dependency).
# This tests the delegation/no-delegation feature of the load_page_fault_exception
# In general, tests should be conducted in order.
# Memory location PT_ROOT_ADDR:PT_ROOTADDR+1f contains page table entry (Do not to overwrite them) 

#include "compliance_test.h"
#include "compliance_io.h"
#include "test_macros.h"

# Test Virtual Machine (TVM) used by program.
RV_COMPLIANCE_RV32M

#define MISA_SUPERVISOR 18
#define LOAD_RESTRICTED_MEMORY 0x90000000
#define PT_ROOT_ADDR 0x80001000 # address aligned to 4 KiB memory.

# Test code region
RV_COMPLIANCE_CODE_BEGIN

    RVTEST_IO_INIT
    RVTEST_IO_ASSERT_GPR_EQ(x0, 0x00000000)
    RVTEST_IO_WRITE_STR("# Test Begin Reserved regs ra(x1) a0(x10) a1(x11) t0(x5) t1(x6) gp(x3) sp(x2) \n")
    
    // Assert
    
    RVTEST_START

    la      s0 , test_res

    # Setting up Page table
  
    # Page table root address
    li      t6 , PT_ROOT_ADDR # PTE address

    # 1. PTE at 0x80001008 | VPN[2] = 1 
    li      t5 , LOAD_RESTRICTED_MEMORY  # point to load_access_fault
    srli    t5 , t5, 12  #To make sure that the page is pointing to the address (without the last 12 bits for offset)
    slli    t5 , t5 , PTE_PPN_SHIFT
    addi    t5 , t5 , PTE_A+PTE_R+PTE_W+PTE_X+PTE_V 
    sd      t5 , 8(t6) # t5 = valid PTE

    # 2. PTE at 0x80001010 | VPN[2] = 2 
    la      t5 , load_loc
    srli    t5 , t5, 12  #To make sure that the page is pointing to the address (without the last 12 bits for offset)
    slli    t5 , t5 , PTE_PPN_SHIFT 
    addi    t5 , t5 , PTE_A+PTE_R+PTE_W+PTE_X+PTE_V 
    sd      t5 , 16(t6) # t5 = valid PTE
    
    # 3. PTE at 0x80001018 | VPN[2] = 3     
    la      t5 , end_loc
    srli    t5 , t5 , 12  #To make sure that the page is pointing to the address (without the last 12 bits for offset)
    slli    t5 , t5 , PTE_PPN_SHIFT 
    addi    t5 , t5 , PTE_A+PTE_R+PTE_W+PTE_X+PTE_V 
    sd      t5 , 24(t6) # t5 = valid PTE
    j       1f

    # Note ! Translation by 2 and 3 PTE does the same address transalation as last 12 bts of address
    # (offset) is unchanged if store_loc and end_loc stays within the address of 0x80000000 : 0x80001000.    
    # But the code is adaptable to these differences.     
    # (Generally: Within the same 4KiB aligned space). 

load_loc:
    li      t4 , 0x40000000 # points to 1st PTE
    lw      t5 , (t4)
    j       test_end

end_loc:
    .word   0x30200073 # illegal instruction (mret) in S mode (check point)
    j       test_end # to prevent unforseen execution

1:
    # Configuring SATP register
    li      t5 , 0x8000000000080001 # satp value mode = 9 and address(80001000)/2^12 = 0x80001
    csrw    satp , t5
    sfence.vma  # sfence to flush local hardware caches related to address translation.   

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
    RVTEST_PART_START(2, "# medeleg[CAUSE_LOAD_PAGE_FAULT] should not be hardwired to 1 \n");
    RVTEST_PART_SKIP(2, "MISA_S_WARL_fn: [WARL_fn, 0]");

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_part_3 # skip if no supervisor mode
   
    li      t5, 1<<CAUSE_LOAD_PAGE_FAULT
    csrc    medeleg , t5
    csrr    t5, medeleg
    srl     t5, t5, CAUSE_LOAD_PAGE_FAULT
    andi    t5, t5, 1
    bnez    t5, test_end 
  
    RVTEST_PART_END(2)

   # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(3, "# when medeleg.[CAUSE_LOAD_PAGE_FAULT]=0, exception should not be delegated to S mode");
    RVTEST_PART_SKIP(3, "MISA_S_WARL_fn: [WARL_fn, 0]");
    
    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_end#test_part_4 # skip if no supervisor mode  

    # Disable delegation of instruction_page_fault_exception
    li t4 , 1<<CAUSE_LOAD_PAGE_FAULT
    csrc medeleg,t4
    
    # Loading the reference value for comparison.
    li      s1 , 0xff
    li      s2 , 3

    # address loaded into mepc after exception. Used in exception handler.
    la s3, 1f 

    # Load mepc with proper virtual address
    la      t5 , load_loc
    li      t4 , 0x0000000000000fff
    and     t5,t5,t4 # loading the offset value
    li      t4 , 0x80000000 # points to 2nd PTE
    add     t4,t4,t5
    csrw mepc, t4

    # Enter supervisor mode.
    li t4, MSTATUS_MPP
    csrc mstatus, t4
    li t4, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_S
    csrs mstatus, t4
    mret 

1:  bne     s1 , s2 , test_end

    RVTEST_PART_END(3)

   # ---------------------------------------------------------------------------------------------   
    RVTEST_PART_START(4, "# when medeleg.[CAUSE_LOAD_PAGE_FAULT]=1, exception should be delegated to S mode. \n");
    RVTEST_PART_SKIP(4, "MISA_S_WARL_fn: [WARL_fn, 0]");
    RVTEST_PART_SKIP(4, "MEDELEG_LOAD_PAGE_FAULT_WARL_fn,[WARL_fn, 0]"); 

    li      t5, 1 << MISA_SUPERVISOR
    csrs    misa , t5
    csrr    t5, misa
    srl     t5, t5, MISA_SUPERVISOR
    andi    t5, t5, 1
    beqz    t5, test_end # skip if no supervisor mode
    
    # check if medeleg[CAUSE_LOAD_PAGE_FAULT] can be set, skip test otherwise
    li t5, 1 << CAUSE_LOAD_PAGE_FAULT
    csrs medeleg, t5 // change it to csrs soon
    csrr t5, medeleg
    srl t5, t5, CAUSE_LOAD_PAGE_FAULT
    andi t5, t5, 1
    beqz t5, test_end
    
    # Dependency on illegal_instruction_exception.
    li t5, 1 << CAUSE_ILLEGAL_INSTRUCTION
    csrc medeleg, t5
    csrr t5, medeleg
    srl t5, t5, CAUSE_ILLEGAL_INSTRUCTION
    andi t5, t5, 1
    bnez t5, test_end

    # Loading the reference value for comparison.
    li      s1 , 0xff
    li      s2 , 1

    # Loading the stvec with proper virtual address
    la      t5 , end_loc
    li      t4 , 0x0000000000000fff
    and     t5,t5,t4 # loading the offset value
    li      t4 , 0xc0000000 # points to 3rd PTE
    add     t4,t4,t5
    csrw    stvec , t4    

    # address loaded into mepc after exception. Used in exception handler.
    la s3, 1f 

    # Load mepc with proper virtual address
    la      t5 , load_loc
    li      t4 , 0x0000000000000fff
    and     t5,t5,t4 # loading the offset value
    li      t4 , 0x80000000 # points to 2nd PTE
    add     t4,t4,t5
    csrw mepc, t4

    # Enter supervisor mode.
    li t4, MSTATUS_MPP
    csrc mstatus, t4
    li t4, (MSTATUS_MPP & -MSTATUS_MPP) * PRV_S
    csrs mstatus, t4
    mret 

1:  bne     s1 , s2 , test_end

    RVTEST_PART_END(4)    

# ---------------------------------------------------------------------------------------------   
   
   j       test_end

# machine mode trap handler & Returns to machine mode permanently  

mtvec_handler:

    # loadi return address
    csrw    mepc , s3    
    
    # Check if scause is loaded with instruction_page_fault
    csrr    t5 , mcause
    li      t2 , CAUSE_ILLEGAL_INSTRUCTION
    bne     t5 , t2, 2f
    csrr    t5 , scause
    li      t2 , CAUSE_LOAD_PAGE_FAULT 
    li      s1 , 1
    beq     t5 , t2, 1f
   
    # Store MCAUSE
2:  csrr    t5 , mcause
    li      t2 , CAUSE_LOAD_PAGE_FAULT
    bne     t5 , t2, test_end
    li      s1 , 3

    # Reformatting mstatus to keep in machine mode
1:  li      t5, MSTATUS_MPP
    csrs    mstatus , t5
    mret

# Supervisor exception handler

stvec_handler:

    # load return address
    csrw    sepc, s3
    
    # Store SCAUSE
    csrr    t5 , scause
    li      t2 , CAUSE_LOAD_PAGE_FAULT 
    bne     t5 , t2, test_end
    csrw    scause , x0
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
