.. _quickstart:

##########
Quickstart
##########

This doc is meant to serve as a quick-guide to setup RISCOF and perform a sample compliance check
between ``spike`` (DUT in this case) and ``riscvOVPsim`` (Golden model in this case).

Install Python
==============

Ubuntu
------

Ubuntu 17.10 and 18.04 by default come with python-3.6.9 which is sufficient for using riscv-config.

If you are are Ubuntu 16.10 and 17.04 you can directly install python3.6 using the Universe
repository::

  $ sudo apt-get install python3.6
  $ pip3 install --upgrade pip

If you are using Ubuntu 14.04 or 16.04 you need to get python3.6 from a Personal Package Archive 
(PPA)::

  $ sudo add-apt-repository ppa:deadsnakes/ppa
  $ sudo apt-get update
  $ sudo apt-get install python3.6 -y 
  $ pip3 install --upgrade pip

You should now have 2 binaries: ``python3`` and ``pip3`` available in your $PATH. 
You can check the versions as below::

  $ python3 --version
  Python 3.6.9
  $ pip3 --version
  pip 20.1 from <user-path>.local/lib/python3.6/site-packages/pip (python 3.6)

Centos:7
--------
The CentOS 7 Linux distribution includes Python 2 by default. However, as of CentOS 7.7, Python 3 
is available in the base package repository which can be installed using the following commands::

  $ sudo yum update -y
  $ sudo yum install -y python3
  $ pip3 install --upgrade pip

For versions prior to 7.7 you can install python3.6 using third-party repositories, such as the 
IUS repository::

  $ sudo yum update -y
  $ sudo yum install yum-utils
  $ sudo yum install https://centos7.iuscommunity.org/ius-release.rpm
  $ sudo yum install python36u
  $ pip3 install --upgrade pip

You can check the versions::

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

Install RISCOF
==============

.. note:: If you are using `pyenv` as mentioned above, make sure to enable that environment before
 performing the following steps.

.. code-block:: bash

  $ pip3 install riscof

To update an already installed version of RISCOF to the latest version:

.. code-block:: bash

  $ pip3 install -U riscof

To checkout a specific version of riscof:

.. code-block:: bash

  $ pip3 install riscof==1.x.x

Once you have RISCOF installed, executing ``riscof --help`` should print the following on the terminal:

.. code-block:: bash


    usage: riscof [-h] [--version] [--verbose]
                  {gendb,setup,validateyaml,run,testlist} ...
    
    This program checks compliance for a DUT.
    
    optional arguments:
      --verbose             [Default=info]
      --version, -v         Print version of RISCOF being used
      -h, --help            show this help message and exit
    
    Action:
      The action to be performed by riscof.
    
      {gendb,setup,validateyaml,run,testlist}
                            List of actions supported by riscof.
        gendb               Generate Database for the standard suite.
        setup               Initiate setup for riscof.
        validateyaml        Validate the Input YAMLs using riscv-config.
        run                 Run the tests on DUT and reference and compare
                            signatures.
        testlist            Generate the test list for the given DUT and suite.
                            Uses the compliance suite by default.
    Action 'gendb'
    
    	usage: riscof gendb [-h] [--suite PATH]
    	
    	optional arguments:
    	  --suite PATH  The Path to the custom suite directory.
    	  -h, --help    show this help message and exit
    	
    Action 'setup'
    
    	usage: riscof setup [-h] [--dutname NAME] [--refname NAME]
    	
    	optional arguments:
    	  --dutname NAME  Name of DUT plugin. [Default=spike]
    	  --refname NAME  Name of Reference plugin. [Default=riscvOVPsim]
    	  -h, --help      show this help message and exit
    	
    Action 'validateyaml'
    
    	usage: riscof validateyaml [-h] [--config PATH]
    	
    	optional arguments:
    	  --config PATH  The Path to the config file. [Default=./config.ini]
    	  -h, --help     show this help message and exit
    	
    Action 'run'
    
    	usage: riscof run [-h] [--config PATH] [--suite PATH] [--no-browser]
    	
    	optional arguments:
    	  --config PATH  The Path to the config file. [Default=./config.ini]
    	  --no-browser   Do not open the browser for showing the test report.
    	  --suite PATH   The Path to the custom suite directory.
    	  -h, --help     show this help message and exit
    	
    Action 'testlist'
    
    	usage: riscof testlist [-h] [--config PATH] [--suite PATH]
    	
    	optional arguments:
    	  --config PATH  The Path to the config file. [Default=./config.ini]
    	  --suite PATH   The Path to the custom suite directory.
    	  -h, --help     show this help message and exit
    
    
Install RISCV-GNU Toolchain
===========================

This guide will use the 32-bit riscv-gnu tool chain to compile the compliance suite.
If you already have the 32-bit gnu-toolchain available, you can skip to the next section.

.. note:: The git clone and installation will take significant time. Please be patient. If you face
   issues with any of the following steps please refer to
   https://github.com/riscv/riscv-gnu-toolchain for further help in installation.


Ubuntu Users
------------

.. code-block:: bash
  
  $ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev \
        libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
        patchutils bc zlib1g-dev libexpat-dev
  $ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
  $ git clone --recursive https://github.com/riscv/riscv-opcodes.git
  $ cd riscv-gnu-toolchain
  $ ./configure --prefix=/path/to/install --with-arch=rv32gc --with-abi=ilp32d # for 32-bit toolchain
  $ [sudo] make # sudo is required depending on the path chosen in the previous setup

CentosOS/RHEL
-------------

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

Install DUT and Golden Models
=============================

This guide is going to prove compliance of the spike model (the DUT) against the riscvOVPsim model
(the Golden model), both of which need to be installed.

Installing SPIKE (a.k.a riscv-isa-sim)
--------------------------------------

.. code-block:: bash

  $ git clone https://github.com/riscv/riscv-isa-sim.git
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
  

Installing riscvOVPsim
----------------------

.. code-block:: bash

  $ git clone https://github.com/riscv/riscv-ovpsim.git --recursive
  $ export PATH=$PATH:<path_downloaded>/riscv-ovpsim/bin/Linux64/

Once installed, open a new terminal and check the version::

  $ riscvOVPsim.exe --version 
  20200206.0


Create Necessary Env Files
==========================

RISCOF requires python plugins for each model (DUT and Golden) to be submitted. These plugins
provide a quick and standard way of building the model, compiling the tests and executing the tests
on the models. Along with the python plugins of each model, one would also have to provide the
`YAML` configuration files of the DUT as per the norms of ``riscv-config``. Some models might also
require special macros to be executed as prelude or post-testing. These macros can be provided to
RISCOF as a header file: ``compliance_model.h``. 

For the sake of this guide, we will use some of the pre-built plugins for riscof available at: 
`riscof-plugins <https://gitlab.com/incoresemi/riscof-plugins>`_. We will specifically use the
spike_simple and riscvOVPsim plugins. 

.. note:: If you are using `pyenv` as mentioned above, make sure to enable that environment before
  performing the following steps since we will now start using riscof.

.. code-block:: bash
  
  $ git clone https://gitlab.com/incoresemi/riscof-plugins.git

To create necessary environment files use the following command::

  $ riscof setup --dutname=spike_simple --refname=riscvOVPsim

The above command will generate a file named ``config.ini`` and a folder named ``spike_simple``.
The ``config.ini`` file is used to capture specific paths of the plugins of reference and DUT model,
along with the paths to isa and platform input YAMLs. The folder ``spike_simple`` contains 
various templates of files that would be required for compliance of any generic DUT. 
Components of this folder will be modified by the user as per the DUT spec. 
Since we are going to use pre-built plugins for this guide, we will ignore the ``spike_simple``
folder for now. 

.. note:: For specific examples on modifications to environment files, please check the 
   corresponding files for various targets available in the riscof-plugins directory.

Based on the path you have downloaded the riscof-plugins directory, you will need to modify the
``config.ini`` file to look similar to the following::


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

We are now ready to run compliance via RISCOF

Running RISCOF
==============

The RISCOF run is divided into three steps as shown in the overview Figure.
The first step is to check if the input yaml files are configured correctly. This step internally calls
the ``riscv-config`` on both the isa and platform yaml files indicated in the ``config.ini`` file.

.. code-block:: bash

  riscof validateyaml --config=config.ini

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

  riscof testlist --config=config.ini

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

  riscof run --config=config.ini

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
