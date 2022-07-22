.. _arch-tests:

########################
Running RISCV-ARCH-TESTS
########################

The following guide provides a walkthrough on how to run the tests available at 
the `riscv-arch-test <https://github.com/riscv/riscv-arch-test>`_ repository.

The following assumes you have installed RISCOF as a cli on your system. If not, then please refer
to the :ref:`install_riscof` section for the same.



Setup all the DUT and Ref Plugins
---------------------------------

  1. You will first need to install the SAIL C-emulator on your system.  You can refer to the
     :ref:`plugin_models` section for steps on installing the SAIL C-emulator.
  2. You will then need to download/clone the ``sail_cSim`` RISCOF plugin. You can do this with the
     following command:

     .. code-block:: console

        $ cd ~/
        $ git clone https://github.com/rems-project/sail-riscv.git

     You will need the path of the `riscof-plugins` directory from the above repo for the next
     steps.

  3. You will also need to create a RISCOF plugin for you own DUT. If you haven't already done so,
     please refer to the :ref:`plugins` section for details on building one.

Create a config.ini file
------------------------

  1. You will need to create a `config.ini` file with the following contents.

    .. code-block:: ini

      [RISCOF]
      ReferencePlugin=sail_cSim
      ReferencePluginPath=/path/to/sail-riscv/riscof-plugins/sail_cSim
      DUTPlugin=<your-dut-name>
      DUTPluginPath=/path/to/your/dut-directory
      
      ## Example configuration for spike plugin.
      [dut-name]
      pluginpath=/path/to/your/dut-directory
      ispec=/path/to/your/dut-directory/dut_isa.yaml
      pspec=/path/to/your/dut-directory/dut_platform.yaml
      
      [sail_cSim]
      pluginpath=/path/to/sail-riscv/riscof-plugins/sail_cSim

    .. tip:: For details on the various configuration options supported by the *sail_cSim* plugin refer `here <csim_docs_>`_.

.. _csim_docs: https://github.com/rems-project/sail-riscv/riscof-plugins/README.md

Cloning the riscv-arch-test repo
--------------------------------

  1. You will also need to download/clone the riscv-arch-test repository:

    .. code-block:: console
        
        $ riscof --verbose info arch-test --clone

Running Tests with RISCOF
-------------------------

  1. Run the tests using the following:

     .. code-block:: console

       $ riscof --verbose info run --config ./config.ini --suite ./riscv-arch-test/riscv-test-suite/rv32i_m --env ./riscv-arch-test/riscv-test-suite/env

     The above step will first create a database of the all tests from the ``rv32i_m`` directory 
     (recursively). This database can be found in the `riscof_work/database.yaml` file that is 
     generated. From this database, RISCOF selects the applicable test depending on the ISA YAML 
     provided and then runs them first on the DUT and then on the REFERENCE plugins. The end, it
     compares the signatures and provides an html report of the result.

     .. note:: Make sure to change the paths in the above command or even the test-suite directory
        to ``rv64i_m`` as the case maybe.
