YAML Specifications
-------------------

This section provides details of the ISA and Platform spec YAML files that need to be provided by the user.

WARL field Restriction Proposal
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since the RISC-V privilege spec indicates several CSRs and sub-fields of CSRs to be WARL (Write-Any-Read-Legal), it is now necessary to provide a scheme of WARL functions which can be used to precisely define the functionality of any such WARL field/register.

The following proposal for WARL functions was made by **Allen Baum (: esperanto)** and has been adopted in this framework.

1. **Range** (*range-warl-func*)

  * represented as a list of 2 or 1 element list where each represents a set.
  * Legal values are defined as every value present in the union of disjoint sets represented in the list. 
  * Each set is represented as (lower,upper) i.e any value>=lower and value<=upper belongs to the set.
  * When an illegal value is written (*WriteVal*) to this field, the next valid value of the field can be deduced based on the following modes(*range-update-warl-func*):
      * Unchanged: The value remains unchanged
      * Nextup: ceiling(*WriteVal*) i.e. the next larger or the largest element of the list
      * Nextdown: floor(*WriteVal*) i.e. the next smallest or the smallest element of the list
      * Nearup: celing(*WriteVal*) i.e. the closest element in the list, with the larger element being chosen in case of a tie.
      * Neardown: floor(*WriteVal*) i.e. the closes element in the list, with the smaller element being chosen in case of a tie
      * Largest: maximum of all legal values
      * Smallest: minimum of all legal values
      * Addr: 
        .. code-block:: python
    
          if ( WriteVal < base || WriteVal > bound)
             return Flip-MSB of field

**Example**:

.. code-block:: python

  range:
    rangelist: [[256,300],[25],[30],[350,390]]
    mode: Addr
    

2. **Bitmask** (*bitmask-warl-func*)

  * This function is represented with 2 fields: the *mask* and the *default*
  * For the read only positions, the corresponding bits are cleared (=0) in the *mask* and the rest of the bits are set (=1).
  * In the *default* field the values for the read only bits are given ( = 0 or 1) and the rest of the bits are cleared (=0).

**Example**:

.. code-block:: python

  bitmask:
    mask: 0x214102D
    default: 0x100


.. _isa_yaml_spec:

ISA YAML Spec
^^^^^^^^^^^^^^^^^

This section describes each node of the ISA-YAML. For each node, we have identified the fields required
from the user and also the various constraints involved.

All fields accept values as integers or hexadecimals(can be used interchangeably) unless specified otherwise.

An elaborate example of the full-fledge ISA-YAML file can be found here: `ISA-YAML <https://gitlab.com/incoresemi/riscof/blob/master/Examples/template_isa.yaml>`_


.. autoyaml:: ../rips/schema-isa.yaml

.. _platform_yaml_spec:

Platform YAML Spec
^^^^^^^^^^^^^^^^^^^^^^

This section describes each node of the PLATFORM-YAML. For each node, we have identified the fields required
from the user and also the various constraints involved.

An eloborate example of the full-fledge PLATFORM-YAML file can be found here: `PLATFORM-YAML <https://gitlab.com/incoresemi/riscof/blob/master/Examples/template_platform.yaml>`_


.. autoyaml:: ../rips/schema-platform.yaml

.. _environment_yaml_spec:

Environment YAML Spec
^^^^^^^^^^^^^^^^^^^^^

The following variables are available and will be replaced before execution of command.
  * *${testDir}*-The absolute path to the test directory containing the generated files for the current test.
  * *${elf}*-The absolute path to the elf file generated after compilation.
  * *${isa}*-The absolute path to the ISA spec yaml for DUT.
  * *${platform}*-The absolute path to the Platform spec yaml for DUT.

This section describes each node of the ENVIRONMENT-YAML. 
An example of the ENV yaml for spike is available: `HERE <https://gitlab.com/incoresemi/riscof/blob/master/Examples/template_env.yaml>`_

.. autoyaml:: ../Examples/template_env.yaml



