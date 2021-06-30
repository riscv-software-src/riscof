.. _arch-tests:

########################
Running RISCV-ARCH-TESTS
########################

The following guide provides a walkthrough on how to run the tests available at 
the `riscv-arch-tests <https://github.com/riscv/riscv-arch-test>`_ repository.

The following assumes you have installed riscof as a cli on your system. If not, then please refer
to the :ref:`install_riscof` section for the same.



Setup all the DUT and Ref Plugins
  1. You will first need to install the SAIL C-emulator on your system.  You can refer to the
     :ref:`plugin_models` section for steps on installing the SAIL C-emulator.
  2. You will then need to download/clone the ``sail_cSim`` riscof plugin. You can do this with the
     following command:

     .. code-block:: console

        $ cd ~/
        $ git clone https://gitlab.com/incoresemi/riscof-plugins.git

  3. You will also need to create a riscof-plugin for you own DUT. If you haven't already done so,
     please refer to the :ref:`plugins` section for details on building one.

Create a config.ini file
  1. You will need to create a `config.ini` file with the following contents.

    .. code-block:: ini

      [RISCOF]
      ReferencePlugin=sail_cSim
      ReferencePluginPath=/path/to/riscof-plugins/sail_cSim
      DUTPlugin=<your-dut-plugin-name>
      DUTPluginPath=/path/to/your/dut-plugin-directory
      
      ## Example configuration for spike plugin.
      [dut-plugin-name]
      pluginpath=/path/to/your/dut-plugin-directory
      ispec=/path/to/your/dut-plugin-directory/dut_isa.yaml
      pspec=/path/to/your/dut-plugin-directory/dut_platform.yaml
      
      [sail_cSim]
      pluginpath=/path/to/riscof-plugins/sail_cSim

Cloning the riscv-arch-test repo
  1. You will also need to download/clone the riscv-arch-test repository:

    .. code-block:: console
        
        $ cd ~/
        $ git clone https://github.com/riscv/riscv-arch-test.git

Running Tests with RISCOF
  1. Run the tests using the following:

     .. code-block:: console

       $ riscof --verbose run --config ~/config.ini --suite ~/riscv-arch-test/riscv-test-suite/rv32i_m --env ~/riscv-arch-test/riscv-test-suite/env

     The above step will first create a database of the all tests from the ``rv32i_m`` directory 
     (recursively). This database can be found in the `riscof_work/database.yaml` file that is 
     generated. From this database, RISCOF selects the applicable test depending on the ISA yaml 
     provided and then runs them first on the DUT and then on the REFERENCE plugins. The end, it
     compares the signatures and provides an html report of the result.

     .. note:: Make sure to change the paths in the above command or even the test-suite directory
        to ``rv64i_m`` as the case maybe.
