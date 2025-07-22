
.. highlight:: shell

.. _coverage:

Format for Privileged Coverpoints
=================================

This section describes the structure and techniques for writing expressions used to verify privileged mode behavior, CSR values, virtual memory permissions, and physical memory protection (PMP) configurations. These techniques are used in RISCOF-compatible coverage files for `riscv-arch-test`.
Coverpoints in this format can leverage set-based operations, macros, bit masking, and indexed selection to concisely define comprehensive and reusable test conditions.


Checking the Current Privilege Mode
-----------------------------------

To determine the privilege level under which an instruction is being executed, you can use the expression::

    mode == "M"

This checks whether the processor is executing in Machine mode. Similar checks can be made for Supervisor and User mode. Mode changes can be tracked using ``mode_change`` in coverage expressions. For example::

   mode_change == "S to M"

Similarly, we can check for ``"U to M"`` and ``"M to M"``. This allows coverage to monitor and validate control flow transitions between different privilege levels.


Evaluating CSR Values
---------------------

Control and Status Register (CSR) values can be directly used in Boolean expressions. For example, to verify that the `satp` register is pointing to the correct root page table, you can use::

    ((satp) & 0x003FFFFF) == get_addr("rvtest_Sroot_pg_tbl") >> 12

This expression masks the lower 22 bits of `satp` and compares it against the address of the label ``rvtest_Sroot_pg_tbl``.

You can also evaluate whether specific CSR bits are set using encodings from ``riscv-arch-test/coverage/header_file.yaml``. For example::

    (mstatus & ${MSTATUS_SUM}) == ${MSTATUS_SUM}

Here, ``${MSTATUS_SUM}`` is a placeholder that gets replaced by its encoding from the YAML file. In this case::

    MSTATUS_SUM: 0x00040000

This expression verifies whether the `SUM` bit in `mstatus` is set. Using macro expansion makes your expressions more portable and easier to maintain.

Similarly, we can perform bitmask operations to verify specific field settings. For instance::

   ((pmpcfg0 >> 8) & 0x9F == 0x99)

This expression shifts the PMP configuration register `pmpcfg0` right by 8 bits and masks selected bits. It then checks if the configuration corresponds to a specific expected value (`0x99`).


Understanding Page Table Walks and PTE Permissions
--------------------------------------------------

In virtual memory tests, it's critical to verify not just the address translation outcome but also the structure of the page table walk and the permissions encoded in PTEs.

The helper function ``get_pte_prop()`` is used to inspect permission bits in a given PTE.

- `dptw1cont` is the descriptor for the Level 1 page table entry.
- `dptw0cont` is the descriptor for the Level 0 page table entry.
- A value of `None` indicates that the page table walk did not proceed to that level.

In ``get_pte_prop("RWxV", ...)``, uppercase characters represent **required set bits**, and lowercase represent **required unset bits**. Here `V`, `R` & `W` must be set while `X` must be unset.

For example, to confirm that a Level 1 PTE was a valid leaf with the correct permissions::

    mode == "S" and get_pte_prop("RWxV", dptw1cont) == 1 and dptw0cont == None

This expression ensures that the walk terminated at level 1, and that the PTE has **Read** and **Write** set and **Execute** bit not set, with no further walk to level 0.

For Level 0 PTE validation, a similar check might be::

    get_pte_prop("rwx", dptw1cont) == 1 and get_pte_prop("RWxV", dptw0cont) == 1

Here, the Level 1 PTE (``dptw1cont``) points to another PTE, and is validated to have none of the leaf permissions (`r`, `w`, `x` unset). The actual permissions are then validated in the Level 0 PTE.


Verifying Faults Using `mcause`
-------------------------------

To check whether a particular page fault occurred, you can evaluate the value of the ``mcause`` CSR.

For example, to verify an **instruction fetch page fault**, use::


    mcause == ${CAUSE_FETCH_PAGE_FAULT}

This symbolic macro expands to the actual cause code (e.g., `12`), and similar expressions can be used for load, store and other faults.


Capturing Coverage for Specific Instructions
--------------------------------------------

The ``mnemonics`` field defines which instructions should be considered for coverage. For example::

    "{sw, csrrc, csrrs, csrrw, lw, jalr}": 0

This means that coverage will only be recorded when any of these instructions are executed.

You can further combine ``mnemonic`` with other conditions. For instance::

    mode == "S" and mnemonic == "sw" and get_pte_prop("urwX", dptw1cont) == 1 and dptw0cont == None and mcause == 15

This expression ensures that a **store page fault** occurred (`mcause == 15`) during the execution of a **sw** instruction in Supervisor mode. It also checks that the Level 1 PTE had certain permissions and the walk did not proceed to Level 0.


Using Sets for Multi-Case Expressions
-------------------------------------

Instead of writing multiple similar expressions, you can use set notation to group values. For example, writing ``{1, 2, 3}: 0`` automatically expands to::

    1: 0
    2: 0
    3: 0

This technique helps reduce repetition and makes the coverage model easier to maintain. It can be used to define sets of conditions, perform cross combinations, or drive parameterized coverage points.

Let us look at some examples to see how this is applied in virtual memory and PMP scenarios. For example, the following two expressions::

    mode == "S" and get_pte_prop("RWX", dptw1cont) == 1 and dptw0cont == None
    mode == "U" and get_pte_prop("RWX", dptw1cont) == 1 and dptw0cont == None

can be combined as::

    mode == {"S", "U"} and get_pte_prop("RWX", dptw1cont) == 1 and dptw0cont == None

You can increase test case permutations using nested sets and parameterized expressions. For example::

    mode == {"S", "U"} and get_pte_prop({"uRWX", "URWX"}{[$1]}, dptw1cont) == 1 and dptw0cont == None

This expression checks **both permissions** against **both modes**. The ``[$1]`` ensures one to one mapping betwenn different sets, i.e. ``(S, uRWX)`` and ``(U, URWX)``. Without ``[$1]`` the values are cross checked as ``(S, uRWX)``, ``(S, URWX)``, ``(U, uRWX)`` and ``(U, URWX)``.

This selection mechanism is also utilized in PMP coverpoints to perform bit-wise manipulations on CSR registers. For example::

   (pmpcfg{{0 ... 15} >> 2} >> {0, 8, 16, 24}{[$2%4]} & 0x80 == 0x80) and (((old_csr_val("pmpcfg$2") ^ pmpcfg$2) >> $3 & 0xFF) == 0x00) and old_csr_val("pmpcfg$2") != 0: 0

Explanation:

- ``{0 ... 15}`` produces a set containing elements from ``0 to 15``. ``$1`` actually gives us the index of the element being selected from this set.
- ``{{0 ... 15} >> 2}`` produces the set ``{0, 1, 2, 3}``. ``$2`` is the index into this derived set.
- ``$2 % 4`` gives a selector for the third set ``{0, 8, 16, 24}``. As we are using ``$2`` in this expression, we are selecting the second set ``{0, 1, 2, 3}`` to compare the current (third) set with. 
- For an element at index 1 from the second set ``{0, 1, 2, 3}``, ``($2 % 4) = (1 % 4) = 1``. It will give us the element at index 1 from the set ``{0, 8, 16, 24}[1] → 8``. 
- This evaluates to the following::

    (pmpcfg0 >> 0 & 0x80 == 0x80) and (((old_csr_val("pmpcfg0") ^ pmpcfg0) >> 0 & 0xFF) == 0x00) and old_csr_val("pmpcfg0") != 0: 0
    (pmpcfg1 >> 8 & 0x80 == 0x80) and (((old_csr_val("pmpcfg1") ^ pmpcfg1) >> 8 & 0xFF) == 0x00) and old_csr_val("pmpcfg1") != 0: 0
    (pmpcfg2 >> 16 & 0x80 == 0x80) and (((old_csr_val("pmpcfg2") ^ pmpcfg2) >> 16 & 0xFF) == 0x00) and old_csr_val("pmpcfg2") != 0: 0
    (pmpcfg3 >> 24 & 0x80 == 0x80) and (((old_csr_val("pmpcfg3") ^ pmpcfg3) >> 24 & 0xFF) == 0x00) and old_csr_val("pmpcfg3") != 0: 0

Similarly, the following example illustrates a related usage. A total of 16 cross checks will be generated by this one line::

   (pmpcfg{{0 ... 15} >> 2} >> {0, 8, 16, 24}{[$1%4]} & 0x80 == 0x80) and (old_csr_val("pmpaddr$1") == (pmpaddr$1)) and (pmpcfg$2 != 0): 0

Here:

- As we are using ``$1``, we are actually selecting set 3 to be compared with set 1. ``{0, 8, 16, 24}`` with set ``{0 ... 15}``.
- ``$1`` is the index of the set ``{0 ... 15}``, and the set ``{0, 8, 16, 24}`` is being indexed by ``$1 % 4``.
- When index 7 of the set ``{0 ... 15}`` is selected, ``7 % 4 = 3`` will select ``24`` from the set ``{0, 8, 16, 24}``. This single case is evaluated to::
          
    (pmpcfg1 >> 24 & 0x80 == 0x80) and (old_csr_val("pmpaddr7") == (pmpaddr7)) and (pmpcfg1 != 0): 0

It is to be noted that ``pmpcfg{{0 ... 15} >> 2}`` will still shift 7 by 2 and form ``pmpcfg1``.


Custom Macro Definitions
--------------------------

The ``header_file.yaml`` file allows to define **custom macros** for use in coverage expressions.
These macros simplify complex constants, addresses, and permission strings, improving readability and maintainability.

Below is an example of macro definitions under ``SV32_MACROS`` in ``header_file.yaml``::

    SV32_MACROS:
      LEVEL_1_JUMP_SIZE: (0x400000 - 4)
      LEVEL_0_JUMP_SIZE: (0x1000 - 4)
      read: "RWX"
      writ: "rx"
      va_data_sv32: (0x91400000)

These macros can represent jump offsets, access permission encodings, or commonly used virtual addresses.

Macros can be used directly in expressions via ``${MACRO_NAME}`` syntax. Here's an example that combines multiple macros::

    mode == "M" and (${va_data_sv32} + ${LEVEL_1_JUMP_SIZE}) == mtval and mcause == ${CAUSE_FETCH_PAGE_FAULT}

This expression checks whether the faulting virtual address stored in ``mtval`` matches the expected location.

To keep the coverage expressions readable and manageable, long expressions can be moved to macros in ``header_file.yaml``. For example, the following macro is used to detect NAPOT region matches::

   NAPOT_REGION_ADDRESS_MATCH: ((rs1_val + imm_val) ^ (pmpaddr1<<2)) & ~(((pmpaddr1 ^ (pmpaddr1+1))<<2) | 3) == 0 and
                               ((rs1_val+imm_val+access_len-1) ^ (pmpaddr1<<2)) & ~(((pmpaddr1 ^ (pmpaddr1+1))<<2) | 3) == 0

This macro simplifies address matching logic required for testing NAPOT-aligned PMP entries and can be reused across multiple test cases without cluttering the coverpoint.
