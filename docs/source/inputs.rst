.. _inputs:

###########################
Understanding RISCOF Inputs
###########################

There are three major inputs that are required by most of the subcommand of RISCOF listed in the
:ref:`commands` section:

1. The ``config.ini`` file
2. The ``DUT plugin directory``
3. The ``Reference plugin directory``

This section will discuss each of the above requirements in detail

.. _config_syntax:

Config.ini Syntax
=================

The ``config.ini`` file follows the `ini <https://en.wikipedia.org/wiki/INI_file>`_ syntax and is 
used to specify the name of the dut and reference plugins, path of the model plugins, plugin
specific parameters and paths to the DUT's riscv-config based isa and platform yamls.


A generic format of the ``config.ini`` file required by RISCOF is presented below. A similar
template file can be generated using the ``--setup`` command of RISCOF.

.. code-block:: ini

   [RISCOF]
   ReferencePlugin=<name-of-ref-plugin>
   ReferencePluginPath<path-to-ref-plugin>
   DUTPlugin=<name-of-dut-plugin>
   DUTPluginPath=<path-to-dut-plugin>

   [dut-name]
   pluginpath=<path-to-dut-plugin>
   ispec=<path-to-isa-spec>
   pspec=<path-to-platform-spec>
   jobs=<num-of-jobs> #OPTIONAL
   PATH=<executable-path> #OPTIONAL

   [ref-name]
   pluginpath=<path-to-dut-plugin>
   jobs=<num-of-jobs> #OPTIONAL
   PATH=<executable-path> #OPTIONAL


The config file also allows you to define specific nodes/fields
which can be used by the respective model plugins. For e.g., in the above template the
`pluginpath` variable under the `[dut-name]` header is available to the DUT Python plugin file 
via RISCOF. The plugin may use this pluginpath to detect the ``env`` files, scripts and other
collaterals that may be required during execution.

Similarly one can define more variables and prefixes here which can directly be
used in the respective plugins. This allows one to build parameterized and configurable plugins, the
values of which are defined in the the ``config.ini`` file.

For example, in the case of sail we can define a ``PATH`` variable which can point to where the C
emulator binaries are located. This allows the plugin to directly probe the variable and use this
as part of the execution commands.

The idea here is to have a single place of change which is easy rather than hard-coding the same
within the plugins.

File path specification
-----------------------

Different values are allowed for the entries in ``config.ini`` to specify a path.
They are checked in the following order, with the first found valid entry being used:

1. Absolute path: Usage of user home (``~``) is allowed.
2. Relative to current working directory: The path within the location where RISCOF command was
   executed.
3. Relative to ``config.ini`` location: A path starting from the point where ``config.ini`` is stored.

.. _plugin_directory:

Model Plugin Directories
========================

Majority of the RISCOF commands also require access to the DUT and Reference Model plugins for
successful execution. 

A typical DUT plugin directory has the following structure::

 ├──dut-name/                    # DUT plugin templates
    ├── env
    │   ├── link.ld              # DUT linker script
    │   └── model_test.h         # DUT specific header file
    ├── riscof_dut-name.py       # DUT Python plugin
    ├── dut-name_isa.yaml        # DUT ISA yaml based on riscv-config
    └── dut-name_platform.yaml   # DUT Platform yaml based on riscv-config

A typical Reference directory has the following structure::

 ├──ref-name/                    # Reference plugin templates
    ├── env
    │   ├── link.ld              # Reference linker script
    │   └── model_test.h         # Reference specific header file
    ├── riscof_ref-name.py       # Reference Python plugin


env directory
-------------

The ``env`` directory in each must contain:

  - ``model_test.h`` header file which provides the model specific macros as described in the
    `TestFormat Spec
    <https://github.com/riscv/riscv-arch-test/blob/master/spec/TestFormatSpec.adoc>`_.
  - ``link.ld`` linker script which can be used by the plugin during test-compilation.

The ``env`` folder can also contain other necessary plugin specific files for pre/post processing of
logs, signatures, elfs, etc.

YAML specs
----------

The yaml specs in the DUT plugin directory are the most important inputs to the RISCOF framework.
All decisions of filtering tests depend on the these YAML files. The files must follow the
syntax/format specified by `riscv-config <https://github.com/riscv/riscv-config>`_. These YAMLs are
validated in RISCOF using riscv-config. 

The YAMLs are only required for the DUT plugin, since the reference plugin should use the same YAMLS
for its configuration and execution.

.. note:: It is not necessary to have the YAML files in the plugin directory, but is recommended as
   a good practice. The files can exist anywhere in your system, as long as the respective paths in
   the ``config.ini`` file correctly point to it.

Python Plugin
-------------

The Python files prefixed with ``riscof_`` are the most important component of the model plugins.
These Python files define how the particular model compiles a test, runs it on the DUT and extracts the
signature.

To provide a standardized interface for all models, the Python plugins must define all actions of
the model under specific functions defined by the :ref:`abstract_class` 
specified by RISCOF. A more detailed explanation on how to build this file for you model can be
found in the :ref:`plugin_def` section.
