.. _quickstart:

##########
Quickstart
##########

This doc is meant to serve as a quick-guide to setup RISCOF and perform a sample compliance check
between ``spike`` (DUT in this case) and ``riscvOVPsim`` (Golden model in this case).

Install Python Dependencies
---------------------------

RISCOF requires `pip` and `python` (>=3.7) to be available on your system. If you have issues, instead of
installing either of these directly on your system, we suggest using a virtual environment
like `pyenv` to make things easy.

Installing Pyenv [optional]
^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you are working on Ubuntu/Debian systems make sure you have the following libraries installed:

.. code-block:: bash

  $ sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
      libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
      xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

Download and install pyenv:

.. code-block:: bash

  $ curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

Add the following lines to your .bashrc:

.. code-block:: bash

  $ export PATH="/home/<username>/.pyenv/bin:$PATH"
  $ eval "$(pyenv init -)"
  $ eval "$(pyenv virtualenv-init -)"

Open a new terminal and create a virtual environment using the following

.. code-block:: bash

  $ pyenv install 3.7.0
  $ pyenv virtualenv 3.7.0 riscof_env


Now you can activate this virtual environment using the following command:

.. code-block:: bash

  $ pyenv activate riscof_env
  $ python --version

Install RISCOF
-----------------

**NOTE**: If you are using `pyenv` as mentioned above, make sure to enable that environment before
performing the following steps.

.. code-block:: bash

  $ pip install riscof

To update an already installed version of RISCOF to the latest version:

.. code-block:: bash

  $ pip install -U riscof

To checkout a specific version of riscof:

.. code-block:: bash

  $ pip install riscof==1.x.x

Once you have RISCOF installed, executing ``riscof --help`` should print the following on the terminal:

.. code-block:: bash

  usage: riscof [-h] --config PATH [--setup] [--validateyaml] [--testlist]
                [--run] [--verbose] [--suite PATH] [--dutname NAME]
                [--refname NAME] [--version]
  
  This program checks compliance for a DUT.
  
  optional arguments:
    --config PATH   The Path to the config file.
    --dutname NAME  Name of DUT plugin.
    --refname NAME  Name of Reference plugin.
    --run           Run riscof in current directory.
    --setup         Initiate setup for riscof.
    --suite PATH    The Path to the custom suite directory.
    --testlist      Generate the testlist only.
    --validateyaml  Validate the Input YAMLs using riscv-config
    --verbose       debug | info | warning | error
    --version, -v   Print version of RISCOF being used
    -h, --help      show this help message and exit

Install RISCV-GNU Toolchain
---------------------------

This guide will use the 32-bit riscv-gnu tool chain to compile the compliance suite.

**NOTE**: The git clone and installation will take significant time. Please be patient!

.. code-block:: bash

  $ mkdir /path/to/install/riscv/toolchain
  $ export RISCV=/path/to/install/riscv/toolchain
  $ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev
  $ git clone --recursive https://github.com/riscv/riscv-opcodes.git
  $ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
  $ cd riscv-gnu-toolchain
  $ ./configure --prefix=$RISCV --with-arch=rv32gc --with-abi=ilp32d # for  32-bit toolchain
  $ make

Make sure to add the path ``/path/to/install/riscv/toolchain/bin`` to your `$PATH` in the .bashrc
With this you should now have all the following available as command line arguments:

.. code-block:: bash

  riscv32-unknown-elf-addr2line      riscv32-unknown-elf-elfedit
  riscv32-unknown-elf-ar             riscv32-unknown-elf-g++
  riscv32-unknown-elf-as             riscv32-unknown-elf-gcc
  riscv32-unknown-elf-c++            riscv32-unknown-elf-gcc-8.3.0
  riscv32-unknown-elf-c++filt        riscv32-unknown-elf-gcc-ar
  riscv32-unknown-elf-cpp            riscv32-unknown-elf-gcc-nm
  riscv32-unknown-elf-gcc-ranlib     riscv32-unknown-elf-gprof
  riscv32-unknown-elf-gcov           riscv32-unknown-elf-ld
  riscv32-unknown-elf-gcov-dump      riscv32-unknown-elf-ld.bfd
  riscv32-unknown-elf-gcov-tool      riscv32-unknown-elf-nm
  riscv32-unknown-elf-gdb            riscv32-unknown-elf-objcopy
  riscv32-unknown-elf-gdb-add-index  riscv32-unknown-elf-objdump
  riscv32-unknown-elf-ranlib         riscv32-unknown-elf-readelf
  riscv32-unknown-elf-run            riscv32-unknown-elf-size
  riscv32-unknown-elf-strings        riscv32-unknown-elf-strip

Install DUT and Golden Models
-----------------------------

This guide is going to prove compliance of the spike model (the DUT) against the riscvOVPsim model
(the Golden model), both of which need to be installed.

Installing SPIKE (a.k.a riscv-isa-sim)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

  $ git clone https://github.com/riscv/riscv-isa-sim.git
  $ export RISCV=/path/to/install/riscv/toolchain
  $ cd riscv-isa-sim
  $ mkdir build
  $ cd build
  $ ../configure --prefix=$RISCV
  $ make
  $ make install

Once installed, executing ``spike-help`` should print the following on your terminal:

.. code-block::

  Spike RISC-V ISA Simulator 1.0.1-dev
  
  usage: spike [host options] <target program> [target options]
  Host Options:
    -p<n>                 Simulate <n> processors [default 1]
    -m<n>                 Provide <n> MiB of target memory [default 2048]
    -m<a:m,b:n,...>       Provide memory regions of size m and n bytes
                            at base addresses a and b (with 4 KiB alignment)
    -d                    Interactive debug mode
    -g                    Track histogram of PCs
    -l                    Generate a log of execution
    -h, --help            Print this help message
    -H                    Start halted, allowing a debugger to connect
    --isa=<name>          RISC-V ISA string [default RV64IMAFDC]
    --varch=<name>        RISC-V Vector uArch string [default v128:e32:s128]
    --pc=<address>        Override ELF entry point
    --hartids=<a,b,...>   Explicitly specify hartids, default is 0,1,...
    --ic=<S>:<W>:<B>      Instantiate a cache model with S sets,
    --dc=<S>:<W>:<B>        W ways, and B-byte blocks (with S and
    --l2=<S>:<W>:<B>        B both powers of 2).
    --log-cache-miss      Generate a log of cache miss
    --extension=<name>    Specify RoCC Extension
    --extlib=<name>       Shared library to load
    --rbb-port=<port>     Listen on <port> for remote bitbang connection
    --dump-dts            Print device tree string and exit
    --disable-dtb         Don't write the device tree blob into memory
    --dm-progsize=<words> Progsize for the debug module [default 2]
    --dm-sba=<bits>       Debug bus master supports up to <bits> wide accesses [default 0]
    --dm-auth             Debug module requires debugger to authenticate
    --dmi-rti=<n>         Number of Run-Test/Idle cycles required for a DMI access [default 0]
    --dm-abstract-rti=<n> Number of Run-Test/Idle cycles required for an abstract command to execute [default 0]
    --dm-no-hasel         Debug module supports hasel
    --dm-no-abstract-csr  Debug module won't support abstract to authenticate
    --dm-no-halt-groups   Debug module won't support halt groups


Installing riscvOVPsim
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

  $ git clone https://github.com/riscv/riscv-ovpsim.git --recursive
  $ export PATH=$PATH:<path_downloaded>/riscv-ovpsim/bin/Linux64/

Once installed, executing ``riscvOVPsim.exe --version`` should print the version of the binary:

.. code-block:: bash

  $ riscvOVPsim.exe --version 
  20200206.0


Create Neccesary Env Files
--------------------------

RISCOF requires python plugins for each model (DUT and Golden) to be submitted. These plugins
provide a quick and standard way of building the model, compiling the tests and executing the tests
on the models. Along with the python plugins of each model, one would also have to provide the
`YAML` configuration files of the DUT as per the norms of ``riscv-config``. Some models might also
require special macros to be executed as prelude or post-testing. These macros can be provided to
RISCOF as a header file: ``compliance_model.h``. 

For the sake of this guide, we will use some of the pre-built plugins for riscof available at: 
`riscof-plugins <https://gitlab.com/incoresemi/riscof-plugins>`_. We will specifically use the
spike_simple and riscvOVPsim plugins for
this guide. 

**NOTE**: If you are using `pyenv` as mentioned above, make sure to enable that evironment before
performing the following steps since we will now start using riscof.

.. code-block:: bash
  
  git clone https://gitlab.com/incoresemi/riscof-plugins.git
  cd riscof-plugins

Copy the ``conig.ini`` file generated using the ``--setup`` above and make sure to change the
ReferencePluginPath, DUTPluginPath and the ispec/pspec paths. The final config.ini should look
similar to :
  
.. code-block:: bash

  [RISCOF]                                                                                            
  ReferencePlugin=riscvOVPsim                                                                         
  ReferencePluginPath=/path/to/riscof-plugins/riscvOVPsim                                             
  DUTPlugin=spike_simple                                                                        
  DUTPluginPath=/path/to/riscof-plugins/spike_simple                                                  
                                                                                                      
  ## Example configuration for spike plugin.                                                          
  [spike_simple]                                                                                             
  pluginpath=/path/to/riscof-plugins/spike_simple/
  ispec=/path/to/riscof-plugins/spike_simple/spike_simple_isa.yaml                                           
  pspec=/path/to/riscof-plugins/spike_simple/spike_simple_platform.yaml 



Running RISCOF
--------------

The RISCOF run is divided into three steps as shown in the overview Figure.
The first step is to check if the input yaml files are configured correctly. This step internally calls
the ``riscv-config`` on both the isa and platform yaml files indicated in the ``config.ini`` file.

.. code-block:: bash

  riscof --config=config.ini --validateyaml

This should print the following:

.. code-block:: bash

  [INFO]    : Reading configuration from: /scratch/git-repo/incoresemi/riscof-plugins/config.ini
  [INFO]    : Preparing Models
  [INFO]    : Input-ISA file
  [INFO]    : Loading input file: /scratch/git-repo/incoresemi/riscof-plugins/spike_simple/sample_isa.yaml
  [INFO]    : Load Schema /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscv_config/schemas/schema_isa.yaml
  [INFO]    : Initiating Validation
  [INFO]    : No Syntax errors in Input ISA Yaml. :)
  [INFO]    : Dumping out Normalized Checked YAML: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/sample_isa_checked.yaml
  [INFO]    : Input-Platform file
  [INFO]    : Loading input file: /scratch/git-repo/incoresemi/riscof-plugins/spike_simple/sample_platform.yaml
  [INFO]    : Load Schema /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscv_config/schemas/schema_platform.yaml
  [INFO]    : Initiating Validation
  [INFO]    : No Syntax errors in Input Platform Yaml. :)
  [INFO]    : Dumping out Normalized Checked YAML: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/sample_platform_checked.yaml

The next step is generate the list of tests that need to be run on the models for declaring
compliance.

.. code-block:: bash

  riscof --config=config.ini --testlist

This step calls the validate-step and thus the output adds one more line to the above dump:

.. code-block:: bash

  [INFO]    : Selecting Tests.

The tests are listed in the file: ``riscof_work/test_list.yaml`` which should probably look
something similar to the following:

.. code-block:: yaml

  suite/rv32i_m/C/C-ADD.S:                                                                            
    work_dir: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/rv32i_m/C/C-ADD.S               
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
    test_path: /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscof/suite/rv32i_m/C/C-ADD.S
  suite/rv32i_m/C/C-ADDI.S:                                                                           
    work_dir: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/rv32i_m/C/C-ADDI.S              
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
    test_path: /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscof/suite/rv32i_m/C/C-ADDI.S
  suite/rv32i_m/C/C-ADDI16SP.S:                                                                       
    work_dir: /scratch/git-repo/incoresemi/riscof-plugins/riscof_work/rv32i_m/C/C-ADDI16SP.S          
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
  ...
  ...
  ...

The last step is to run the tests on the each of the models and compare the signature values to
guarantee correctness. 

.. code-block:: bash

  riscof --config=config.ini --run

This should compile and execute the tests on each of the models and end up with the following log:


.. code-block:: bash

  ...
  ...
  ...
  [INFO]    : Initiating signature checking.
  [INFO]    : Following 55 tests have been run :
  
  [INFO]    : TEST NAME                                          : COMMIT ID                                : STATUS
  [INFO]    : suite/rv32i_m/I/I-ADD-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-ADDI-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-AND-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-ANDI-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-AUIPC-01.S                       : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-BEQ-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-BGE-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-BGEU-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-BLT-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-BLTU-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-BNE-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-CSRRC-01.S                       : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-CSRRCI-01.S                      : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-CSRRS-01.S                       : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-CSRRSI-01.S                      : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-CSRRW-01.S                       : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-CSRRWI-01.S                      : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-DELAY_SLOTS-01.S                 : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-EBREAK-01.S                      : 3a4a3a576666d5153ae6a844e74a45f953245e57 : Passed
  [INFO]    : suite/rv32i_m/I/I-ECALL-01.S                       : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-ENDIANESS-01.S                   : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-FENCE.I-01.S                     : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-IO.S                             : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-JAL-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-JALR-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-LB-01.S                          : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-LBU-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-LH-01.S                          : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-LHU-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-LUI-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-LW-01.S                          : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-MISALIGN_JMP-01.S                : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-MISALIGN_LDST-02.S               : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-NOP-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-OR-01.S                          : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-ORI-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-RF_size-01.S                     : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-RF_width-01.S                    : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-RF_x0-01.S                       : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SB-01.S                          : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SH-01.S                          : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SLL-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SLLI-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SLT-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SLTI-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SLTIU-01.S                       : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SLTU-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SRA-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SRAI-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SRL-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SRLI-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SUB-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-SW-01.S                          : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-XOR-01.S                         : d50921ef64708678832770fd842355aa2b0684af : Passed
  [INFO]    : suite/rv32i_m/I/I-XORI-01.S                        : d50921ef64708678832770fd842355aa2b0684af : Passed

And will also open a HTML page with all the information.
