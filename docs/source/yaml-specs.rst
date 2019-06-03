YAML Specifications
-------------------

This section provides details of the ISA and Platform spec YAML files that need to be provided by the user.

WARL field Restriction Proposal
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since the RISC-V privilege spec indicates several CSRs and sub-fields of CSRs to be WARL (Write-Any-Read-Legal), it is now necessary to provide a scheme of WARL functions which can be used to precisely define the functionality of any such WARL field/register.

The following proposal for WARL functions was made by **Allen Baum (: esperanto)** and has been adopted in this framework.

1. **Distinct** (*distinct-warl-func*) 

  * A list of distinct values which are considered as legal and any value not in the list is considered as illegal.
  * When an illegal value is written (*WriteVal*) to this field, the next valid value of the field can be deduced based on the following modes(*distinct-update-warl-func*):
      * UnChgd: The value remains unchanged
      * NextUp: ceiling(*WriteVal*) i.e. the next larger or the largest element of the list
      * NextDown: floor(*WriteVal*) i.e. the next smalles or the smallest element of the list
      * NearUp: celing(*WriteVal*) i.e. the closest element in the list, with the larger element being chosen in case of a tie.
      * NearDown: floor(*WriteVal*) i.e. the closes element in the list, with the smaller element being chosen in case of a tie
      * Largest: maximum of all legal values
      * Smallest: minimum of all legal values

**Example**:

.. code-block:: python

  distinct:
    values: [0,55,658,1026]
    mode: "UnChgd"
    
2. **Range** (*range-warl-func*)

  * Legal values are defined as all values that lie within the set: *[base, bound]* inclusive
  * When an illegal value is written (*WriteVal*) to this field, the next valid value of the field can be deduced based on the following modes(*range-update-warl-func*):
      * Saturate: 

        .. code-block:: python 

          if ( WriteVal < base )
             return base; 
          else if( WriteVal > bound )
             return bound;
          else 
             return no-change


      * UnChgd

        .. code-block:: python
    
          if ( WriteVal < base || WriteVal > bound)
             return no-change

      * Addr: 

        .. code-block:: python
    
          if ( WriteVal < base || WriteVal > bound)
             return Flip-MSB of field

**Example**:

.. code-block:: python

  range:
    base: 256
    bound: 0xFFFFFFFFFFFFFF00
    mode: Saturate
    

*Proposal* (By **Allen Baum (: esperanto)**): 
To treat this field as a list of lists i.e. take in multiple pairs of base and bounds and a value lying inbetween any one of the pairs is considered legal.

3. **Bitmask** (*bitmask-warl-func*)

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

An elaborate example of the full-fledge ISA-YAML file can be found here: `ISA-YAML <https://gitlab.com/incoresemi/riscof/blob/1-general-improvements-and-standardisation-of-schema-yaml/Examples/eg_elaborate_isa.yaml>`_


.. autoyaml:: ../rips/schema-isa.yaml

.. _platform_yaml_spec:

Platform YAML Spec
^^^^^^^^^^^^^^^^^^^^^^

This section describes each node of the PLATFORM-YAML. For each node, we have identified the fields required
from the user and also the various constraints involved.

An eloborate example of the full-fledge PLATFORM-YAML file can be found here: `PLATFORM-YAML <https://gitlab.com/incoresemi/riscof/blob/1-general-improvements-and-standardisation-of-schema-yaml/Examples/eg_elaborate_platform.yaml>`_


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
An example of the ENV yaml for spike is available: `HERE <https://gitlab.com/incoresemi/riscof/blob/1-general-improvements-and-standardisation-of-schema-yaml/Examples/template_env.yaml>`_

.. autoyaml:: ../Examples/template_env.yaml



