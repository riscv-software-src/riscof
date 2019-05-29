YAML Specifications
-------------------

This section provides details of the ISA and Platform spec YAML files that need to be provided by the user.

WARL field Restriction Proposal
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since the RISC-V privilege spec indicates several CSRs and sub-fields of CSRs to be WARL (Write-Any-Read-Legal), it is now necessary to provide a scheme of WARL functions which can be used to precisely define the functionality of anysuch WARL field/register.

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

    
2. **Range** (*range-warl-func*)

  * Legal values are defined as all values that lie within the set: *[Lower, Upper]* inclusive
  * When an illegal value is written (*WriteVal*) to this field, the next valid value of the field can be deduced based on the following modes(*range-update-warl-func*):
      * Saturate: 

        .. code-block:: python 

          if ( WriteVal < Lower )
             return Lower; 
          else if( WriteVal > Upper )
             return Upper;
          else 
             return no-change


      * UnChgd

        .. code-block:: python
    
          if ( WriteVal < Lower || WriteVal > Upper)
             return no-change

      * Addr: 

        .. code-block:: python
    
          if ( WriteVal < Lower || WriteVal > Upper)
             return Flip-MSB of field


3. **Bitmask** (*bitmask-warl-func*)

  * This function is represented with 2 fields: the *Base* and the *Value*
  * For the read only positions, the corresponding bits are cleared (=0) in the *Base* and the rest of the bits are set (=1).
  * In the *Value* field the values for the read only bits are given ( = 0 or 1) and the rest of the bits are cleared (=0).


These fields can be implemented as one of the following three types.

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

This section describes each node of the ENVIRONMENT-YAML. 

.. autoyaml:: ../Examples/template_env.yaml



