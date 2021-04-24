############
Introduction
############

**RISCOF** - The RISC-V Compatibility Framework is a python based framework which enables testing of a RISC-V
target (hard or soft implementations) against a standard RISC-V golden reference model using a suite
of RISC-V architectural assembly tests.


.. _intent:

Intent of the architectural test suite
======================================

The RISC-V Architectural Tests are an evolving set of tests that are created to help ensure that 
software written for a given RISC-V Profile/Specification will run on all implementations that 
comply with that profile.

These tests also help ensure that the implementer has both understood and implemented the specification correctly.

The RISC-V Architectural Test suite is a minimal filter. Passing the tests and having the results 
approved by RISC-V International is a prerequisite to licensing the RISC-V trademarks in connection 
with the design. Passing the RISC-V Architectural Tests does not mean that the design complies with the 
RISC-V Architecture. These are only a basic set of tests checking important aspects of the specification 
without focusing on details.

The RISC-V Architectural Tests are not a substitute for rigorous design verification.

The result that the architecture tests provide to the user is an assurance that the specification 
has been interpreted correctly and the implementation under test (DUT) can be declared as 
RISC-V Architecture Test compliant.

.. _audience:

Target Audience
===============

This document is targeted for the following categories of audience

Users
-----

RISCOF, as a utility is targeted towards verification and design engineers who wish to check if 
their RISC-V implementation (simulation models, HDL models, etc.) is compliant to the RISC-V 
specification. This document will refer to this category of audience as users of RISCOF in the
remaining sections of this document.

Contributors
------------

Engineers who would like to enhance the features of the framework or contribute tests to the
architectural test suite, will be referred to as contributors/developers in the remaining sections of this
document. This framework enables engineers to author scalable and parameterized tests which can
evolve along with the evolution of the specification itself.
