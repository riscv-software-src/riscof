.. See LICENSE.incore for details

.. highlight:: shell

.. _quickstart:

==========
Quickstart
==========

This section is meant to serve as a quick-guide to setup RISCOF and perform a sample validation check
between ``spike`` (DUT in this case) and ``SAIL-RISCV`` (Reference model in this case). This guide
will help you setup all the required tooling for running riscof on your system.

If you would like to know how to build a plugin for your DUT please refer to the :ref:`plugins`
section for more details.

If you have your DUT plugin ready and would like to run the riscv-arch-tests on it using RISCOF,
please refer to section :ref:`arch-tests`

Install Python
==============

.. tabs::

   .. tab:: Ubuntu


      Ubuntu 17.10 and 18.04 by default come with python-3.6.9 which is sufficient for using riscv-config.
      
      If you are are Ubuntu 16.10 and 17.04 you can directly install python3.6 using the Universe
      repository
      
      .. code-block:: shell-session

        $ sudo apt-get install python3.6
        $ pip3 install --upgrade pip
      
      If you are using Ubuntu 14.04 or 16.04 you need to get python3.6 from a Personal Package Archive 
      (PPA)
      
      .. code-block:: shell-session

        $ sudo add-apt-repository ppa:deadsnakes/ppa
        $ sudo apt-get update
        $ sudo apt-get install python3.6 -y 
        $ pip3 install --upgrade pip
      
      You should now have 2 binaries: ``python3`` and ``pip3`` available in your $PATH. 
      You can check the versions as below
      
      .. code-block:: shell-session

        $ python3 --version
        Python 3.6.9
        $ pip3 --version
        pip 20.1 from <user-path>.local/lib/python3.6/site-packages/pip (python 3.6)

   .. tab:: CentOS7

      The CentOS 7 Linux distribution includes Python 2 by default. However, as of CentOS 7.7, Python 3 
      is available in the base package repository which can be installed using the following commands
      
      .. code-block:: shell-session

        $ sudo yum update -y
        $ sudo yum install -y python3
        $ pip3 install --upgrade pip
      
      For versions prior to 7.7 you can install python3.6 using third-party repositories, such as the 
      IUS repository
      
      .. code-block:: shell-session

        $ sudo yum update -y
        $ sudo yum install yum-utils
        $ sudo yum install https://centos7.iuscommunity.org/ius-release.rpm
        $ sudo yum install python36u
        $ pip3 install --upgrade pip
      
      You can check the versions
      
      .. code-block:: shell-session

        $ python3 --version
        Python 3.6.8
        $ pip --version
        pip 20.1 from <user-path>.local/lib/python3.6/site-packages/pip (python 3.6)

Using Virtualenv for Python 
---------------------------

Many a times users face issues in installing and managing multiple python versions. This is actually 
a major issue as many gui elements in Linux use the default python versions, in which case installing
python3.6 using the above methods might break other software. We thus advise the use of **pyenv** to
install python3.6.

For Ubuntu and CentosOS, please follow the steps here: https://github.com/pyenv/pyenv#basic-github-checkout

RHEL users can find more detailed guides for virtual-env here: https://developers.redhat.com/blog/2018/08/13/install-python3-rhel/#create-env

Once you have pyenv installed do the following to install python 3.6.0::

  $ pyenv install 3.6.0
  $ pip3 install --upgrade pip
  $ pyenv shell 3.6.0
  
You can check the version in the **same shell**::

  $ python --version
  Python 3.6.0
  $ pip --version
  pip 20.1 from <user-path>.local/lib/python3.6/site-packages/pip (python 3.6)

.. _install_riscof:

Install RISCOF
==============

.. tabs:: 

   .. tab:: via Git

     To install RISCOF, run this command in your terminal:
     
     .. code-block:: console
     
         $ pip3 install git+https://github.com/riscv/riscof.git
     
     This is the preferred method to install RISCOF, as it will always install the most recent stable release.
     
     If you don't have `pip`_ installed, this `Python installation guide`_ can guide
     you through the process.
     
     .. _pip: https://pip.pypa.io
     .. _Python installation guide: http://docs.python-guide.org/en/latest/starting/installation/

   .. tab:: via Pip

     .. note:: If you are using `pyenv` as mentioned above, make sure to enable that environment before
      performing the following steps.
     
     .. code-block:: bash
     
       $ pip3 install riscof
     
     To update an already installed version of RISCOF to the latest version:
     
     .. code-block:: bash
     
       $ pip3 install -U riscof
     
     To checkout a specific version of RISCOF:
     
     .. code-block:: bash
     
       $ pip3 install riscof==1.x.x

   .. tab:: for Dev

     The sources for RISCOF can be downloaded from the `Github repo`_.
     
     You can clone the repository:
     
     .. code-block:: console
     
         $ git clone https://github.com/riscv/riscof.git
     
     
     Once you have a copy of the source, you can install it with:
     
     .. code-block:: console
         
         $ cd riscof
         $ pip3 install --editable .
     
     .. _Github repo: https://github.com/riscv/riscof

Test RISCOF
===========

Once you have installed RISCOF you can execute ``riscof --help`` to print the help routine:

.. code-block:: bash

    Usage: riscof [OPTIONS] COMMAND [ARGS]...
        
        Options:
          --version                       Show the version and exit.
          -v, --verbose [info|error|debug]
                                          Set verbose level
          --help                          Show this message and exit.
        
        Commands:
          arch-test     Setup and maintenance for Architectural TestSuite.
          coverage      Run the tests on DUT and reference and compare signatures
          gendb         Generate Database for the Suite.
          run           Run the tests on DUT and reference and compare signatures
          setup         Initiate Setup for riscof.
          testlist      Generate the test list for the given DUT and suite.
          validateyaml  Validate the Input YAMLs using riscv-config.

Install RISCV-GNU Toolchain
===========================

This guide will use the 32-bit riscv-gnu tool chain to compile the architectural suite.
If you already have the 32-bit gnu-toolchain available, you can skip to the next section.

.. note:: The git clone and installation will take significant time. Please be patient. If you face
   issues with any of the following steps please refer to
   https://github.com/riscv-collab/riscv-gnu-toolchain for further help in installation.

.. tabs::
   .. tab:: Ubuntu

     .. code-block:: bash
       
       $ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev \
             libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
             patchutils bc zlib1g-dev libexpat-dev
       $ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
       $ git clone --recursive https://github.com/riscv/riscv-opcodes.git
       $ cd riscv-gnu-toolchain
       $ ./configure --prefix=/path/to/install --with-arch=rv32gc --with-abi=ilp32d # for 32-bit toolchain
       $ [sudo] make # sudo is required depending on the path chosen in the previous setup
     
   .. tab:: CentosOS/RHEL
     
     .. code-block:: bash
     
       $ sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel \
             gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
       $ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
       $ git clone --recursive https://github.com/riscv/riscv-opcodes.git
       $ cd riscv-gnu-toolchain
       $ ./configure --prefix=/path/to/install --with-arch=rv32gc --with-abi=ilp32d # for 32-bit toolchain
       $ [sudo] make # sudo is required depending on the path chosen in the previous setup

Make sure to add the path ``/path/to/install`` to your `$PATH` in the .bashrc/cshrc
With this you should now have all the following available as command line arguments::

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

.. _plugin_models:

Install Plugin Models
=====================

This section will walk your throguh installing 2 important RISC-V reference models: Spike and SAIL.
These are often used as reference models in RISCOF.

.. tabs::

  .. tab:: SAIL (SAIL C-emulator)

    **Alternative 1: Local Install**

    .. code-block:: bash

       $ sudo apt-get install opam  build-essential libgmp-dev z3 pkg-config zlib1g-dev
       $ opam init -y --disable-sandboxing
       $ opam switch create ocaml-base-compiler.4.06.1
       $ opam install sail -y
       $ eval $(opam config env)
       $ git clone https://github.com/riscv/sail-riscv.git
       $ cd sail-riscv
       $ make
       $ ARCH=RV32 make
       $ ARCH=RV64 make
       $ ln -s sail-riscv/c_emulator/riscv_sim_RV64 /usr/bin/riscv_sim_RV64
       $ ln -s sail-riscv/c_emulator/riscv_sim_RV32 /usr/bin/riscv_sim_RV32

    This will create a C simulator in ``c_emulator/riscv_sim_RV64`` and
    ``c_emulator/riscv_sim_RV32``. You will not need to add these paths in your ``$PATH`` or an
    alias to it to execute them from command line.

    **Alternative 2: Using Docker**

    For the convenience of the users, a docker image with all the necessary tools is available. The
    plugin also supports using this docker image to generate the reference signatures. 

    .. warning:: Ensure that docker is installed and configured properly before running this step.
    
    The following command can be used to pull the docker image.
    
    .. code-block:: bash
        
        $ docker pull gitlab.incoresemi.com:5050/dockers/docker-compliance
    
  .. tab:: Spike (riscv-isa-sim)

    .. code-block:: bash
   
      $ sudo apt-get install device-tree-compiler
      $ git clone https://github.com/riscv-software-src/riscv-isa-sim.git
      $ cd riscv-isa-sim
      $ mkdir build
      $ cd build
      $ ../configure --prefix=/path/to/install
      $ make
      $ [sudo] make install #sudo is required depending on the path chosen in the previous setup
    
    Make sure to add the path ``/path/to/install`` to your `$PATH` in the .bashrc/cshrc
    Once installed, executing ``spike`` on the terminal should print the following::
    
      usage: spike [host options] <target program> [target options]
      Host Options:
        -p<n>                 Simulate <n> processors [default 1]
        -m<n>                 Provide <n> MiB of target memory [default 2048]
        -m<a:m,b:n,...>       Provide memory regions of size m and n bytes
                                at base addresses a and b (with 4 KiB alignment)
        -d                    Interactive debug mode
        -g                    Track histogram of PCs
        -l                    Generate a log of execution
        -h                    Print this help message
        -H                    Start halted, allowing a debugger to connect
        --isa=<name>          RISC-V ISA string [default RV64IMAFDC]
        --pc=<address>        Override ELF entry point
        --hartids=<a,b,...>   Explicitly specify hartids, default is 0,1,...
        --ic=<S>:<W>:<B>      Instantiate a cache model with S sets,
        --dc=<S>:<W>:<B>        W ways, and B-byte blocks (with S and
        --l2=<S>:<W>:<B>        B both powers of 2).
        --extension=<name>    Specify RoCC Extension
        --extlib=<name>       Shared library to load
        --rbb-port=<port>     Listen on <port> for remote bitbang connection
        --dump-dts            Print device tree string and exit
        --disable-dtb         Don't write the device tree blob into memory
        --progsize=<words>    Progsize for the debug module [default 2]
        --debug-sba=<bits>    Debug bus master supports up to <bits> wide accesses [default 0]
        --debug-auth          Debug module requires debugger to authenticate



Create Neccesary Env Files
==========================

In order to run tests via RISCOF you will need to provide the following items :

  - **config.ini**: This file is a basic configuration file following the `ini` syntax. This file
    will capture information like: name of the dut/reference plugins, path to the plugins, path to
    the riscv-config based yamls, etc. For more information on the contents and syntax please refer
    to the :ref:`config_syntax` section
  - **dut-plugin directory**: RISCOF requires that the DUT model for testing is presented in the
    form of a python plugin. The python plugin is nothing more than a python file which includes
    certain standard and defined functions to carry out the activities of test-compilation,
    execution and signature extraction. This python file name needs to be prefixed with ``riscof_``
    and must be present in the dut-plugin directory. One can refer to the :ref:`plugin_def` section
    for more details on how to write this python file.

    The directory will also need to contain the `riscv-config` based isa and platform yamls which provide
    a definition of the DUT. These yamls will be used to filter tests that need to be run on the
    DUT.

    Finally, an env directory will also need to be present in the dut-plugin directory, which
    contains the environment files like the ``model_test.h`` that is required to compile and run the tests
    on the DUT. Refer to the `TestFormat spec
    <https://github.com/riscv-software-src/riscv-arch-test/blob/master/spec/TestFormatSpec.adoc>`_ for definition of macros that can be used in the
    ``model_test.h`` file. The env directory may also include other files like the linker script,
    post-processing scripts that the user may want.

  - **reference-plugin directory**: Similar to the DUT plugin, RISCOF also expects a reference model
    plugin. The structure of the directory and files is the same as that of the DUT. However, the
    isa and platform yamls are not required since RISCOF will always pick the yamls from the DUT
    plugin for all purposes.

.. For sample templates of pre-built plugins please refer to : `riscof-plugins <https://github.com/riscv/riscof-plugins>`_. 

For sample templates of pre-built plugins please refer to :ref:`prebuilt_plugins`. 

To make things simpler, RISCOF generates standard pre-built templates for DUTs and Reference
Models for the user via the ``setup`` command as shown below::

  $ riscof setup --dutname=spike

The above command will generate the following files and directories in the current directory::

 ├──config.ini                   # configuration file for riscof
 ├──spike/                       # DUT plugin templates
    ├── env
    │   ├── link.ld              # DUT linker script
    │   └── model_test.h         # DUT specific header file
    ├── riscof_spike.py          # DUT python plugin
    ├── spike_isa.yaml           # DUT ISA yaml based on riscv-config
    └── spike_platform.yaml      # DUT Platform yaml based on riscv-config
 ├──sail_cSim/                   # reference plugin templates
    ├── env
    │   ├── link.ld              # Reference linker script
    │   └── model_test.h         # Reference model specific header file
    ├── __init__.py
    └── riscof_sail_cSim.py      # Reference model python plugin.

The generate template ``config.ini`` will look something like this by default::


  [RISCOF]                                                                                            
  ReferencePlugin=sail_cSim
  ReferencePluginPath=/path/to/riscof/sail_cSim
  DUTPlugin=spike                                                                        
  DUTPluginPath=/path/to/riscof/spike                                                  
                                                                                                      
  ## Example configuration for spike plugin.                                                          
  [spike]                                                                                             
  pluginpath=/path/to/riscof/spike/
  ispec=/path/to/riscof/spike/spike_isa.yaml                                           
  pspec=/path/to/riscof/spike/spike_platform.yaml 

  [sail_cSim]
  pluginpath=/path/to/riscof/sail_cSim

If the SAIL binaries (i.e. ``riscv_sim_RV32``) are not in your $PATH you may want to add the following to the last line of the
above config::

  PATH=<path_to_my_Sail_binaries>

To use the docker image(instead of a local sail installation) the ``sail_cSim`` node in the above
snippet should be replaced with the following::

  [sail_cSim]
  pluginpath=/path/to/riscof/sail_cSim
  docker=True
  image=gitlab.incoresemi.com:5050/dockers/docker-compliance


The folder ``spike`` contains various templates of files that would be required for testing of 
any generic DUT. Components of this folder will need to be modified by the user as per the DUT spec.
By default the ``model_test.h`` files and the ``link.ld`` file will work out of the box for
``spike`` and ``sail`` models.

.. note:: Custom DUTs can go through the various ``#TODO`` comments to figure out what changes need to be
  made in the respective python file.

The configuration of spike we will be using is available in the ``spike/spike_isa.yaml``. Modifying
this will change the tests applicable for the DUT. For now let's leave it as is. For more
information on creating and modifying your plugins can be found in :ref:`plugins`

The ``sail_cSim`` directory holds the plugin files for the reference SAIL model. Changes to any of
the files in this directory are typically not required (unless you know what you are doing).

We are now ready to run the architectural tests on the DUT via RISCOF.

.. tip:: By default RISCOF resorts to using RISC-V's SAIL C Emulator as a reference model. To generate
 templates for a reference model add the argument '--refname myref' to the setup command above. This
 will generate a *myref* directory containing template files for defining a reference model plugin.
 Lookout for the #TODO in the python file for places where changes will be required. 

.. tip:: For details on the various configuration options supported by the *sail_cSim* plugin refer `here <csim_docs_>`_.

.. _csim_docs: https://gitlab.incoresemi.com/core-verification/riscof-plugins/-/tree/master/sail_cSim#riscof-plugin-for-sail-risc-v-formal-model 

Cloning the Architectural Tests
===============================

We will be running the tests from the official riscv-arch-test repository on the DUT and Reference
models. To create a copy of the latest tests from the riscv-arch-test repository do the following:

.. code-block:: console
    
    $ riscof --verbose info arch-test --clone

This will create a riscv-arch-test in the current working directory.
   

Running RISCOF
==============

The RISCOF run is divided into three steps as shown in the overview Figure.
The first step is to check if the input yaml files are configured correctly. This step internally calls
the ``riscv-config`` on both the isa and platform yaml files indicated in the ``config.ini`` file.

.. code-block:: bash

  riscof validateyaml --config=config.ini

This should print the following:

.. code-block:: bash

  [INFO]    : Reading configuration from: /scratch/git-repo/incoresemi/riscof/config.ini
  [INFO]    : Preparing Models
  [INFO]    : Input-ISA file
  [INFO]    : Loading input file: /scratch/git-repo/incoresemi/riscof/spike/sample_isa.yaml
  [INFO]    : Load Schema /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscv_config/schemas/schema_isa.yaml
  [INFO]    : Initiating Validation
  [INFO]    : No Syntax errors in Input ISA Yaml. :)
  [INFO]    : Dumping out Normalized Checked YAML: /scratch/git-repo/incoresemi/riscof/riscof_work/sample_isa_checked.yaml
  [INFO]    : Input-Platform file
  [INFO]    : Loading input file: /scratch/git-repo/incoresemi/riscof/spike/sample_platform.yaml
  [INFO]    : Load Schema /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscv_config/schemas/schema_platform.yaml
  [INFO]    : Initiating Validation
  [INFO]    : No Syntax errors in Input Platform Yaml. :)
  [INFO]    : Dumping out Normalized Checked YAML: /scratch/git-repo/incoresemi/riscof/riscof_work/sample_platform_checked.yaml

The next step is to generate the list of tests that need to be run on the models.

.. code-block:: bash

  riscof testlist --config=config.ini --suite=riscv-arch-test/riscv-test-suite/ --env=riscv-arch-test/riscv-test-suite/env

This step calls the validate-step and thus the output adds one more line to the above dump:

.. code-block:: bash

  [INFO]    : Selecting Tests.

The tests are listed in the file: ``riscof_work/test_list.yaml`` which should probably look
something similar to the following:

.. code-block:: yaml

  suite/rv32i_m/C/C-ADD.S:                                                                            
    work_dir: /scratch/git-repo/incoresemi/riscof/riscof_work/rv32i_m/C/C-ADD.S               
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
    test_path: /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscof/suite/rv32i_m/C/C-ADD.S
  suite/rv32i_m/C/C-ADDI.S:                                                                           
    work_dir: /scratch/git-repo/incoresemi/riscof/riscof_work/rv32i_m/C/C-ADDI.S              
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
    test_path: /home/neel/.pyenv/versions/3.7.0/envs/venv/lib/python3.7/site-packages/riscof/suite/rv32i_m/C/C-ADDI.S
  suite/rv32i_m/C/C-ADDI16SP.S:                                                                       
    work_dir: /scratch/git-repo/incoresemi/riscof/riscof_work/rv32i_m/C/C-ADDI16SP.S          
    macros: [TEST_CASE_1=True, XLEN=32]                                                               
    isa: RV32IC                                                                                       
  ...
  ...
  ...

The last step is to run the tests on the each of the models and compare the signature values to
guarantee correctness. 

.. code-block:: bash

  riscof run --config=config.ini --suite=riscv-arch-test/riscv-test-suite/ --env=riscv-arch-test/riscv-test-suite/env

This should compile and execute the tests on each of the models and end up with the following log.
The run will also open an HTML page with all the information.


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


