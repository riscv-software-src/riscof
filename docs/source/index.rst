.. RISV Compliance Framework documentation master file, created by
   sphinx-quickstart on Thu May 23 12:47:39 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to RISV Compliance Framework's documentation!
=====================================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

Documentation for the Code                                                                          
**************************                                                                          
.. toctree::                                                                                        
   :maxdepth: 2                                                                                     
      :caption: Contents:

SchemaValidator
===================                                                                                 
.. automodule:: rips.schemaValidator
   :members: 
   :special-members:
   :private-members:

WARL field function types
============================
These fields can be implemented as one of the following three types.

1) **Distinct** (*distinct-warl-func*)- 

- A list of distinct values which are considered as legal and any value not in the list is considered as illegal.
- The update mode on illegal value write for this type are as follows(*distinct-update-warl-func*)-
         - UnChgd
         - NextUp
         - NextDown
         - NearUp
         - NearDown
         - Largest
         - Smallest
    
2) **Range** (*range-warl-func*) -

- The values >= base(Lower) and <= bound(Upper) are considered legal and anything else as illegal.
- The update mode on illegal value write for this type are as follows(*range-update-warl-func*)-
         - Saturate
         - UnChgd
         - Addr

3) **Bitmask** (*bitmask-warl-func*)-

- For the Read only positions, the corresponding bits are cleared in the base(Base) and the rest of the bits are set.
- In the value(FixedVal) the values for the Read only bits are given and the rest of the bits are cleared.

ISA Schema
=============================

.. autoyaml:: ../rips/schema-isa.yaml


Platform Schema
==============================

.. autoyaml:: ../rips/schema-platform.yaml


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
