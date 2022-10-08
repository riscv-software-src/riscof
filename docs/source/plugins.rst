.. highlight:: shell

.. _plugins:

##########################
Building your Model Plugin
##########################


As mentioned in the :ref:`inputs` section, the DUT and Reference plugin directories (and their
items) are the most crucial components required by the RISCOF framework for successful execution.
This section will walk you through in detail on how to build the various items of the DUT plugin
directories.

A typical DUT plugin directory has the following structure::

 ├──dut-name/                    # DUT plugin templates
    ├── env
    │   ├── link.ld              # DUT linker script
    │   └── model_test.h         # DUT specific header file
    ├── riscof_dut-name.py       # DUT python plugin
    ├── dut-name_isa.yaml        # DUT ISA yaml based on riscv-config
    └── dut-name_platform.yaml   # DUT Platform yaml based on riscv-config

The ``env`` directory in must contain:

  - ``model_test.h`` header file which provides the model specific macros as described in the
    `TestFormat Spec
    <https://github.com/riscv/riscv-arch-test/blob/master/spec/TestFormatSpec.adoc>`_. 
  - ``link.ld`` linker script which can be used by the plugin during test-compilation.

  .. note:: If you have already ported your target to the old architectural test framework, the
     above files can be re-used from that port/target itself.

The ``env`` folder can also contain other necessary plugin specific files for pre/post processing of
logs, signatures, elfs, etc.

The yaml specs in the DUT plugin directory are the most important inputs to the RISCOF framework.
All decisions of filtering tests depend on the these YAML files. The files must follow the
syntax/format specified by `riscv-config <https://github.com/riscv-software-src/riscv-config>`_. These YAMLs are
validated in RISCOF using riscv-config. 

The python plugin files capture the behavior of model for compiling tests, executing them on the DUT
and finally extracting the signature for each test. The following sections provide a detailed
explanation on how to build the python files for your model.

.. hint:: All paths provided by riscof are absolute and it is advised to always use absolute paths while executing/generating commands to avoid errors. 


Start with Templates
====================

A sample template of the plugin and all other required collateral can be generated through RISCOF
using the following command::

  $ riscof setup --refname=sail_cSim --dutname=spike

.. note:: You can change the name from spike to the name of your target

This above command should generate a spike folder with the following contents:

.. code-block:: bash
  :linenos:

  env                          # contains sample header file and linker file   
  riscof_spike.py              # sample spike plugin for RISCOF
  spike_isa.yaml               # sample ISA YAML configuration file
  spike_platform.yaml          # sample PLATFORM YAML configuration file

The command will also generate a sample ``config.ini`` file with the following contents:

.. code-block:: bash
  :linenos:

  [RISCOF]
  ReferencePlugin=cSail                                                                               
  ReferencePluginPath=/scratch/git-repo/incoresemi/riscof/sail_cSim
  DUTPlugin=spike
  DUTPluginPath=/scratch/git-repo/incoresemi/riscof/spike
  
  [spike]
  pluginpath=/scratch/git-repo/incoresemi/riscof/spike
  ispec=/scratch/git-repo/incoresemi/riscof/spike/spike_isa.yaml                                 
  pspec=/scratch/git-repo/incoresemi/riscof/spike/spike_platform.yaml
  target_run=1
  
  [sail_cSim]
  pluginpath=/scratch/git-repo/incoresemi/riscof/sail_cSim

The following changes need to be made:

1. Fix the paths in the ``config.ini`` to point to the folder containing the respective riscof_*.py files.
2. The macros in the ``spike/env/model_test.h`` can be updated/replaced based on the model. Definitions of
   the macros and their use is available in the :ref:`test_format_spec`.
3. Update the ``riscof_<target-name>.py`` with respective functions as described in the following 
   paragraphs.

The plugin file in the ``spike`` folder: riscof_spike.py is the one that needs to be
changed and updated for each model as described in the following sections


Please note the user is free to add more custom functions in this file which are called within the
three base functions (as mentioned above).

Why Python Based Plugins ?
==========================

- Since the entire RISCOF framework is in python it did not make sense to have the 
  user-DUT in a separate environment. It would then cause issues in transferring data across 
  these environments/domains. 
  
- While many prefer the conventional *Makefile/autoconf* approach, transferring the *test-list* in YAML 
  to be used by another Makefile-environment seemed like a bad and an unscalable idea.
  
- Expecting initial hesitation, we have tried to ensure that the python plugins can be made extremely 
  simple (as crude as writing out bash instructions using shellCommand libraries). 
  
- Considering there would be a few backlashes in these choices, we have given enough pit-stops in the 
  flow: ``validation, test-list, coverage, etc`` so one can stop at any point in the flow and move 
  to their custom domain. 

- Having a python plugin **does not change your test-bench** in anyway. The plugins only act as a common
  interface between your environment and RISCOF. All you need to do is call the respective sim
  commands from within the python plugin.
  
If you do feel the flow can be further improved or changed please do drop in an issue on the
official repository.


.. _plugin_def:

Python Plugin file
==================

As can be seen from the above generated template python file, it creates a Metaclass for the plugins 
supported by the :ref:`abstract_class`. This class basically offers the users three basic 
functions: ``initialize`` , ``build`` and ``runTests``. 
For each model RISCOF calls these functions in the following order:

.. code-block:: bash

  initialize --> build --> runTests

These functions have been conceptualized keeping in mind what a typical DUT execution may require.
Instead of having a single complex function, we have split it across 3 functions.

We now define the various arguments and possible functionality of each of the above
mentioned functions. Please note, this is not a strict guide and the users can choose to perform
different actions in different functions as long as
they comply with the order of the functions being called and the signatures are generated in their 
respective directories at the end of the `runTests` function.

.. note:: The contents of the signature file must conform to specification mentioned in the 
  TestFormat Spec `here <https://github.com/riscv/riscv-arch-test/blob/master/spec/TestFormatSpec.adoc#36-the-test-signature>`_

__init__ (self, *args, **kwargs)
--------------------------------

.. hint:: **PYTHON-HINT**: The self variable is used to represent the instance of the class which 
   is often used in object-oriented programming. It works as a reference to the object. Python 
   uses the self parameter to refer to instance attributes and methods of the class. In this 
   guide we use the self parameter to create and access methods declared across the functions 
   within the same class.


This is the constructor function for the pluginTemplate class. The configuration dictionary of the
dut plugin, as specified in the ``config.ini``, is passed to the plugin via the ``**kwargs`` argument.
The typical action in this function would be to capture as much information about the DUT from the
`config.ini` as possible, since the config will not be available as arguments to the remaining
functions.

.. hint:: **PYTHON-HINT**: In Python we use *args and **kwargs as an argument when we are unsure about the number 
   of arguments to pass in the functions. *args allow us to pass the variable number of non 
   keyword arguments to a function. The arguments are passed as a tuple and these passed arguments 
   make tuple inside the function with same name as the parameter excluding asterisk ``*``.

   **kwargs allows us to pass the variable length of keyword 
   arguments to the function. The double asterisk is used to indicate a variable length keyword
   argument. The arguments are passed as a dictionary and these arguments make a dictionary inside 
   function with name same as the parameter excluding double asterisk ``**``.

   As is seen below, we access the config node as ``kwargs.get('config')``

   Refer to this `blog
   <https://www.programiz.com/python-programming/args-and-kwargs#:~:text=*args%20passes%20variable%20number%20of,a%20dictionary%20can%20be%20performed.>`_ for more information

As mentioned, in the :ref:`config_syntax` section, the config.ini file can be used to pass some
common or specific parameters to the python plugin. This makes it easy for users to modify the
parameters in the config.ini file itself, instead of having to change it in the python file.

At minimum, the DUT node of the ``config.ini`` must contain paths to the ISA and Platform yaml specs.
If the DUT node is missing or is empty in the ``config.ini`` this function should throw an error and
exit. This is done in lines 8-10 in the snippet below.

One of the parameters we should capture here would be the path to the simulation executable of
the DUT. In case of an RTL based DUT, this would be point to the final binary executable of your
test-bench produced by a simulator (like verilator, vcs, incisive, etc). In case of an ISS or
Emulator, this variable could point to where the ISS binary is located. This is shown in line-16 in
the below snippet.

Another variable of interest would be the number of parallel jobs that can be spawned off by RISCOF
for various actions performed in later functions, specifically to run the tests in parallel on the
DUT executable. This variable is captured in as the variable ``num_jobs`` in line-21 below. If the
`config.ini` does not have the ``jobs`` variable specified then we default to the value of 1.

The ``target_run`` parameter is used to control if the user would like to stop
after compilation of the tests or continue running the tests on the target and
go on to signature comparison. When set to '0' the plugin must only compile the
tests and exit (using ``raise SystemExit`` in python). When set to ``1`` the
plugin will compile and run the tests on the target. This parameter is captured
in lines 34-37. 

Finally, the mandatory parameters that must be present in the ``config.ini`` for the DUT are the
paths to the riscv-config based ISA and Platform YAML files. These paths are collected in lines
28-29. Remember these are paths to the unchecked version of the yaml and are only captured here to
send them across to the RISCOF framework, where RISCOF will validate them with riscv-config , send
it to the reference model for configuration and also use it filter the tests.
The verified/checked versions of the YAMLs will be provided to the build function.

The above yaml file paths and other arguments are captured in the class methods and returned back to
the RISCOF framework in line 40.

.. code-block:: python
    :linenos:

    def __init__(self, *args, **kwargs):
        sclass = super().__init__(*args, **kwargs)

        config = kwargs.get('config')

        # If the config node for this DUT is missing or empty. Raise an error. At minimum we need
        # the paths to the ispec and pspec files
        if config is None:
            print("Please enter input file paths in configuration.")
            raise SystemExit

        # In case of an RTL based DUT, this would be point to the final binary executable of your
        # test-bench produced by a simulator (like verilator, vcs, incisive, etc). In case of an iss or
        # emulator, this variable could point to where the iss binary is located. If 'PATH variable
        # is missing in the config.ini we can hardcode the alternate here (spike in this case)
        self.dut_exe = os.path.join(config['PATH'] if 'PATH' in config else "","spike")

        # Number of parallel jobs that can be spawned off by RISCOF
        # for various actions performed in later functions, specifically to run the tests in 
        # parallel on the DUT executable. Can also be used in the build function if required.
        self.num_jobs = str(config['jobs'] if 'jobs' in config else 1)

        # Path to the directory where this python file is located. Collect it from the config.ini
        self.pluginpath=os.path.abspath(config['pluginpath'])

        # Collect the paths to the  riscv-config absed ISA and platform yaml files. One can choose
        # to hardcode these here itself instead of picking it from the config.ini file.
        self.isa_spec = os.path.abspath(config['ispec'])
        self.platform_spec = os.path.abspath(config['pspec'])

        #We capture if the user would like the run the tests on the target or
        #not. If you are interested in just compiling the tests and not running
        #them on the target, then following variable should be set to False
        if 'target_run' in config and config['target_run']=='0':
            self.target_run = False
        else:
            self.target_run = True

        # Return the parameters set above back to RISCOF for further processing.
        return sclass

.. warning:: if the config is empty or if the isa and platform yamls are not available in the
   specified paths, the above function shall generate an error and exit.

.. note:: It is not necessary for your config.ini to pass any of these parameters. And one could
   instead hardwire the paths in this function itself. For eg.

   .. code-block:: python

      self.dut_exe = '/scratch/mydut/sim/tb.exe'
      self.num_jobs = 7

Between lines 38-40 one can still add and capture many more DUT specific parameters which could be
useful later. For example,

.. code-block:: python

        # some system may use 'pmake' instead of 'make' for parallel jobs. The following line
        # captures the make command set in the config.ini and defaults to using make otherwise.
        self.make = config['make'] if 'make' in config else 'make'

        # setting the build path for any artifacts generated in the build function
        self.build_path = '/scratch/mybuild/'

Compared to a conventional Makefile flow, this phase would be similar to capturing and setting some
of the DUT specific parameters in a Makefile.include. Many of those variables can be set here and
used later in different contexts.

initialize (self, suite, workdir, archtest_env)
-----------------------------------------------

The primary action here would be to create the templates for the compile and any other pre/post
processing commands that will be required later here. This function provides the following 
arguments which can be used in this function:

1. `suite`: This argument holds the absolute path of the directory where the architectural test suite
   exists.
2. `workdir`: This argument holds the absolute path of the work directory where all the execution
   and meta files/states should be dumped as part of running RISCOF.
3. `archtest_env`: This argument holds the absolute path of the directory where all the
   architectural test header files (``arch_test.h``) are located. This should be used to initialize 
   the include arguments to the compiler/assembler.

Since we have access to the test environment directory here, it would make sense to build a generic
template of the command that we will be using to compile the tests. For example consider the
following python code which sets the compile command to use the riscv-gcc compiler.

.. code-block:: python

   self.compile_cmd = 'riscv{1}-unknown-elf-gcc -march={0} \
         -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g\
         -T '+self.pluginpath+'/env/link.ld\
         -I '+self.pluginpath+'/env/\
         -I ' + archtest_env + '{2} -o {3} {4}'

.. hint:: **PYTHON-HINT**: Python's new style of string formatting makes it quite regular to use.
   One can place curly braces within the string to indicate the point at which a replacement needs
   to be peformed and then use the ``.format(var)`` syntax to assign those values. Curly braces with
   integers in them indicate the argument number which should be used for replacement.

   For example,

   .. code-block:: python

      'My name is {0} and age is {1}'.format('John','20')

   In python one can also use the ``+`` symbol to concatenate strings as is shown in the above
   snippet code, where the include directories are appended at the end


Some folks might build a `riscv32-` toolchain or a `riscv64-` toolchain depending on
their DUT. To be agnostic of this choice, in the above snippet we have left the integer following
`riscv` string to be a variable (defined by ``{1}``. see below hint for python syntax details) 
which will be fixed in the later functions. Based on the DUT one can even hard-code it here and
remove the variable dependence. 

Also, the ``march`` string that a test should be compiled with should not be hardwired here as it
changes from test to test. Hence, we leave it as a variable in the above snippet (defined as
``{0}``). 

The variable ``{2}`` indicates the assembly file of the test that needs to be compiled. 
The variables ``{3}`` and ``{4}`` are used to indicate the output elf name and any compile macros
that need to be assigned respectively. Both of which will be set in the runTests function later.
Remember here, we are assigning this string template to a method in the `self` instance of the class
which can be accessed in other functions as well.


Similar to the compile command above, one can choose to build template for many other commands that
may be required to be executed for each test. For example, some common utilities would be:

.. code-block:: python

   # set the objdump template here. Note we continue with the variable toolchain below. Also the
   # name of the elf is kept a variable to be fixed in the runTests function.
   self.objdump = 'riscv{0}-unknown-elf-objdump -D {1} > test.disass'

   # set the elf2hex command here. This is mostly used by rtl test-benches which use the readmemb or
   # readmemh like utilities to load the test. Note again here, we have kept the name of the elf as
   # variable which will be set in runTests function
   self.elf2hex = elf2hex 8 33554432 {0} 2147483648 > code.mem

The following snippet shows the entire function for reference based on the above discussion. One can
add the above utility snippets  after line 20 below.

.. code-block:: python
   :linenos:

   def initialise(self, suite, work_dir, archtest_env):
      
       # capture the working directory. Any artifacts that the DUT creates should be placed in this
       # directory. Other artifacts from the framework and the Reference plugin will also be placed
       # here itself.
       self.work_dir = work_dir
       
       # capture the architectural test-suite directory. 
       self.suite_dir = suite

       # Note the march is not hardwired here, because it will change for each
       # test. Similarly the output elf name and compile macros will be assigned later in the
       # runTests function
       self.compile_cmd = 'riscv{1}-unknown-elf-gcc -march={0} \
         -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g\
         -T '+self.pluginpath+'/env/link.ld\
         -I '+self.pluginpath+'/env/\
         -I ' + archtest_env + ' {2} -o {3} {4}'

       # add more utility snippets here


This phase is much similar to the setting up command variables in a Makefile. These commands are
generic and parameterized and can be applied to any test.

An example of a more complex compile command is provided below,

.. code-block:: python
   :linenos:

   self.compile_cmd = 'riscv32-uknown-elf-gcc -march={0} \
      -static -mcmodel=medany -g -fvisibility=hidden -nostdlib -nostartfiles \
      -I {1} -I{2} -T{3} -o {4} {5};\
      riscv32-unknown-elf-objcopy -O binary {4} {4}.bin;\
      riscv32-unknown-elf-objdump {4} -D > {4}.objdump;\
      riscv32-unknown-elf-objdump {4} --source > {4}.debug;\
      riscv32-unknown-elf-readelf -a {4} > {4}.readelf;'

In the above snippet the compile command has 6 variables ( indicated by ``{0}`` to ``{5}``). To
assign values to these variables in the later stages, one can use the following syntax. Remember the
order of the arguments in the ``format()`` function below must match the order of variables used
above. Here the arguments of the format function are strings or variable holding the specified
information.

.. code-block:: python
   :linenos:

   self.compile_cmd.format(march_str, testsuite_env, dut_env, dut_link.ld, output_elf, input_asm)

If the integer numbering feels uncomfortable, python also allows name-based substitution which would
like the following:

.. code-block:: python
   :linenos:

   self.compile_cmd = 'riscv32-uknown-elf-gcc -march={testmarch} \
      -static -mcmodel=medany -g -fvisibility=hidden -nostdlib -nostartfiles \
      -I {testenv} -I{dutenv} -T{dutlink} -o {outputelf} {inputasm};\
      riscv32-unknown-elf-objcopy -O binary {outputelf} {outputelf}.bin;\
      riscv32-unknown-elf-objdump {outputelf} -D > {outputelf}.objdump; \
      riscv32-unknown-elf-objdump {outputelf} --source > {outputelf}.debug; \
      riscv32-unknown-elf-readelf -a {outputelf} > {outputelf}.readelf;'

   self.compile_cmd.format(testmarch=march_str, testenv=testsuite_env, dutenv=dut_env,
   dutlink=dut_link.ld, outputelf=output_elf, inputasm=input_asm)

build(self, isa_yaml, platform_yaml)
------------------------------------

This function is primarily meant for building or configuring the DUT (or its runtime arguments) if 
required. This is particularly useful when working with core-generators. This stage can be used to 
generate a specific configuration of the DUT leveraging the specs available in the checked 
ISA and Platform yamls. For example in the case of spike, we can use the ISA yaml to create the
appropriate value of the ``--isa`` argument used by spike.

Apart, from configuring the DUT this stage can also be used to check if all the commands required by
the DUT for successful execution are available or not. For example checking if the compiler is
installed, the dut_exe executable is available, etc.

To enable the above actions the `build` function provides the following arguments to the user:

1. `isa_spec`: This argument holds the absolute path to the validated ISA config YAML. This can be used to extract
   various fields from the YAML (e.g. ISA) and configure the DUT accordingly.
2. `platform_spec`: This argument holds the absolute path to the validated PLATFORM config YAML and can be used
   similarly as above.

Some of the parameters of interest that can be captured in this stage using the isa yaml are:

- the xlen value: this can be obtained from the max value in the ``supported_xlen`` field of the 
  yaml. This is particularly useful in setting the compiler integer number we discussed before and
  also for setting other DUT specific parameters (like the ``--isa`` argument of spike). Shown in
  line 9 below.
- the isa string: for simulators like spike, we can parse this to generate the string for the
  ``--isa`` argument. Shown in lines 13-19 below.

.. hint:: **PYTHON-HINT**: one can access dictionary elements using the square braces ``[]``.


.. note:: For pre-compiled/configured RTL targets this phase is typically empty and no actions are 
   required. Though, one could choose to compile the RTL in this phase if required using simulators
   like verilator, vcs, etc.

An example of this function for an ISS like spike is show below:

.. code-block:: python
   :linenos:

   def build(self, isa_yaml, platform_yaml):

      # load the isa yaml as a dictionary in python. 
      ispec = utils.load_yaml(isa_yaml)['hart0']

      # capture the XLEN value by picking the max value in 'supported_xlen' field of isa yaml. This
      # will be useful in setting integer value in the compiler string (if not already hardcoded);
      # also for setting the '--isa' argument of spike.
      self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')

      # for spike start building the '--isa' argument. the self.isa is spike specific and may not be
      # useful for all DUTs
      self.isa = 'rv' + self.xlen
      if "I" in ispec["ISA"]:
          self.isa += 'i'
      if "M" in ispec["ISA"]:
          self.isa += 'm'
      if "C" in ispec["ISA"]:
          self.isa += 'c'
      
      #TODO: The following assumes you are using the riscv-gcc toolchain. If
      #      not please change appropriately
      self.compile_cmd = self.compile_cmd+' -mabi='+('lp64 ' if 64 in ispec['supported_xlen'] else 'ilp32 ')

runTests(self, testlist)
------------------------

This function is responsible for compiling and executing each test on the DUT and produce individual
signature files, which can later be used for comparison. The function provides a single argument
which is the ``testList``. This argument is available as a python based dictionary and follows the
syntax presented in the :ref:`testlist` section.

The only outcome of this function should be a signature file generated for each test. These
signature files must be located in directory pointed by the ``test_dir`` field of each test in the
testList. The signature files generated by the DUT must conform to the TestFormatSpec and must be
named ``DUT-<dut-name>.signature``. In RISCOF, this can be achieved using the ``self.name`` syntax
and then appending the string ``.signature`` to it.

Also note, the contents of the signature file must conform to specification mentioned in the 
TestFormat Spec `here
<https://github.com/riscv/riscv-arch-test/blob/master/spec/TestFormatSpec.adoc#36-the-test-signature>`_

There are multiple ways of defining this function. We will start with the most simplest version and
move on to more involved variants.

Using Shell Commands
^^^^^^^^^^^^^^^^^^^^

In this variant we will build a simple function which will spawn off individual shell commands to
compile the test, run the test and collect/post-process the signature of each test. An example of
this script is provided below.

.. hint:: **PYTHON-HINT**: To display progress on the terminal it is often good to have some print
   statements in the code. In this plugin we use the logger library from python to achieve this.
   Syntax for usage is::

     logger.debug('My Progress here')

   The keyword 'debug' above indicates that the above statement will be displayed on the terminal
   only when the ``--verbose`` cli argument is set to "debug". Similarly one can create warning and
   error statements (which will be printed in different colors and enabled via the cli)::

     logger.warning('This is enabled when verbose is debug or warning')
     logger.error('This is enabled when verbose is debug, warning or error')

.. code-block:: python
  :linenos:

  def runTests(self, testList):
      
      # we will iterate over each entry in the testList. Each entry node will be referred to by the
      # variable testname.
      for testname in testList:
        
          # for each testname we get all its fields (as described by the testList format)
          testentry = testList[testname]

          # we capture the path to the assembly file of this test
          test = testentry['test_path']

          # capture the directory where the artifacts of this test will be dumped/created.
          test_dir = testentry['work_dir']

          # name of the elf file after compilation of the test
          elf = 'my.elf'

          # name of the signature file as per requirement of RISCOF. RISCOF expects the signature to
          # be named as DUT-<dut-name>.signature. The below variable creates an absolute path of
          # signature file.
          sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")
          
          # for each test there are specific compile macros that need to be enabled. The macros in
          # the testList node only contain the macros/values. For the gcc toolchain we need to
          # prefix with "-D". The following does precisely that.
          compile_macros= ' -D' + " -D".join(testentry['macros'])

          # collect the march string required for the compiler
          marchstr = testentry['isa'].lower()

          # substitute all variables in the compile command that we created in the initialize
          # function
          cmd = self.compile_cmd.format(marchstr, self.xlen, test, elf, compile_macros)

          # just a simple logger statement that shows up on the terminal
          logger.debug('Compiling test: ' + test)

          # the following command spawns a process to run the compile command. Note here, we are
          # changing the directory for this command to that pointed by test_dir. If you would like
          # the artifacts to be dumped else where change the test_dir variable to the path of your
          # choice.
          utils.shellCommand(cmd).run(cwd=test_dir)

	        # if the user wants to disable running the tests and only compile the tests, then
	        # the if condition is skipped
          if self.target_run:
            # build the command for running the elf on the DUT. In this case we use spike and indicate
            # the isa arg that we parsed in the build stage, elf filename and signature filename.
            # Template is for spike. Please change for your DUT
            execute = self.dut_exe + ' --isa={0} +signature={1} +signature-granularity=4 {2}'.format(self.isa, sig_file, elf)
            logger.debug('Executing on Spike ' + execute)

            # launch the execute command. Change the test_dir if required.
            utils.shellCommand(execute).run(cwd=test_dir)

          # post-processing steps can be added here in the template below
          #postprocess = 'mv {0} temp.sig'.format(sig_file)'
          #utils.shellCommand(postprocess).run(cwd=test_dir)

      # if target runs are not required then we simply exit as this point after running all 
      # the makefile targets. 
      if not self.target_run:
        raise SystemExit

As mentioned earlier, the `-march` string is test-specific and needs to be collected from the
testList fields. Line-30 above, shows that ``testentry['isa']`` provides this information. 

.. hint:: **PYTHON-HINT**: the lower() function in line-30 above is used to reduce all the
   characters of a string to lowercase

Note, that as the toolchain and tests evolves, one might need to manipulate this string 
before assigning it to the march argument of the compiler. 

At times, for debug purposes or initial bring up purposes one might want to just compile the tests
and not run them on the DUT. In order to achieve this, one can set the
``target_run`` parameter in the ``config.ini`` file to 0. This will cause lines
47-55 to be skipped and thereby skip from running tests on the target.


.. hint:: **PYTHON-HINT**: Note in python we use ``#`` for comments. Also note, that python uses
   indentation to indicate a block of code (hence the indentation of lines 7 through 58). 

Makefile Flow (Recommended)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

While the previous solution is small and precise, it offers very less debug artifacts. In this
variant we will be generating a single Makefile which can be used outside RISCOF as well to run a
particular or a collection of tests.

The Makefile generated here will have as many targets as there are tests, and each make-target will
correspond to having commands which will compile the test, run on the dut and collect the signature.
To provide ease in creating such a Makefile, RISCOF provides a makeUtility which can be used in this
function.

.. tip:: if one is more well-versed with python, you can choose to create the Makefile differently
   with more custom targets. However, note that the make utility provided from RISCOF might not 
   work for custom Makefiles.

An example of the runTests function which uses the ``makeUtil`` utility is shown below. 
Here a Makefile is first generated where every test is a make target. The utility 
automatically creates the relevant targets and only requires the user to define what should 
occur under each target.

The user can choose to use a different make command by setting
the ``make.makeCommand``. More details of this utility are available at: :ref:`utils`

.. code-block:: bash
  :linenos:

  def runTests(self, testList):
      
      # create an instance the makeUtil class that we will use to create targets.
      make = utils.makeUtil(makefilePath=os.path.join(self.work_dir, "Makefile." + self.name[:-1]))

      # set the make command that will be used. The num_jobs parameter was set in the __init__
      # function earlier
      make.makeCommand = 'make -j' + self.num_jobs

      # we will iterate over each entry in the testList. Each entry node will be refered to by the
      # variable testname.
      for testname in testList:
        
          # for each testname we get all its fields (as described by the testList format)
          testentry = testList[testname]

          # we capture the path to the assembly file of this test
          test = testentry['test_path']

          # capture the directory where the artifacts of this test will be dumped/created. RISCOF is
          # going to look into this directory for the signature files
          test_dir = testentry['work_dir']

          # name of the elf file after compilation of the test
          elf = 'my.elf'

          # name of the signature file as per requirement of RISCOF. RISCOF expects the signature to
          # be named as DUT-<dut-name>.signature. The below variable creates an absolute path of
          # signature file.
          sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")
          
          # for each test there are specific compile macros that need to be enabled. The macros in
          # the testList node only contain the macros/values. For the gcc toolchain we need to
          # prefix with "-D". The following does precisely that.
          compile_macros= ' -D' + " -D".join(testentry['macros'])
          
          # substitute all variables in the compile command that we created in the initialize
          # function
          cmd = self.compile_cmd.format(testentry['isa'].lower(), self.xlen, test, elf, compile_macros)

	        # if the user wants to disable running the tests and only compile the tests, then
	        # the "else" clause is executed below assigning the sim command to simple no action
	        # echo statement. 
          if self.target_run:
            # set up the simulation command. Template is for spike. Please change.
            simcmd = self.dut_exe + ' --isa={0} +signature={1} +signature-granularity=4 {2}'.format(self.isa, sig_file, elf)
          else:
            simcmd = 'echo "NO RUN"'

          # concatenate all commands that need to be executed within a make-target.
          execute = '@cd {0}; {1}; {2};'.format(testentry['work_dir'], cmd, simcmd)

          # create a target. The makeutil will create a target with the name "TARGET<num>" where num
          # starts from 0 and increments automatically for each new target that is added
          make.add_target(execute)
      
      # if you would like to exit the framework once the makefile generation is complete uncomment the
      # following line. Note this will prevent any signature checking or report generation.
      #raise SystemExit

      # once the make-targets are done and the makefile has been created, run all the targets in
      # parallel using the make command set above.
      make.execute_all(self.work_dir)
  
      # if target runs are not required then we simply exit as this point after running all 
      # the makefile targets. 
      if not self.target_run:
          raise SystemExit


.. include:: ../../PLUGINS.rst

Using the Target files from existing framework with riscof
==========================================================
To ease transition from the old framework, the ``makeplugin`` is provided in the IncorePlugins
repository.

Setup
-----

1. Clone the repository using the following command.

    .. code-block:: shell

        git clone https://gitlab.incoresemi.com/core-verification/riscof-plugins.git

2. Modify the following values in the ``config.ini``

    .. code-block:: ini

        DUTPlugin=makeplugin
        DUTPluginPath=<path-to-riscof-plugins>/makeplugin 

3. Add the following node to the ``config.ini``.

   .. code-block:: ini

        [makeplugiun]
        # To specify multiple files use comma separated paths
        makefiles=<path-to-makefile.includes>
        ispec=<path-to-isa-yaml-file>
        pspec=<path-to-platform-yaml-file>

Modifying the makefile
----------------------
The commands in the makefile need to be modified such that the variables from the following tables
are used in the commands. These variables shall be replaced with the appropriate values in the
``RUN_TARGET`` and ``COMPILE_TARGET`` commands.

.. list-table:: 
    :header-rows: 1

    * - Variable Name
      - Description
    * - ``${target_dir}``
      - The directory where the plugin file resides. (riscof_makeplugin.py))
    * - ``${asm}``
      - Absolute path to the assemble test file i.e the .S file for the test.
    * - ``${work_dir}``
      - The absolute path to the work directory for the test.
    * - ``${test_name}``
      - The name of the test, for example add-01 etc. Can be used for naming any intermediate files generated.
    * - ``${include}``
      - The path to the directory which containts the test header files. This needs to be specified as an include path in the compile command.
    * - ``${march}``
      - The ISA to be used for compiling the test. This is in the format expected by march argument of gcc.
    * - ``${mabi}``
      - The abi to be used for compiling the test. This is in the format expected by mabi argument of gcc.
    * - ${target_isa}
      - This is the ISA specified in the input ISA yaml. The idea is that it can be used to configure the model at run time via cli arguments if necessary.
    * - ``${test_bin}``
      - The name of the binary file to be created after compilation. Can be ignored. Custom names can be used as long as the ``RUN_TARGET`` command picks up the correct binary to execute on the target.
    * - ``${signature_file}``
      - The absolute path to the signature file. This path cannot be changed and the signature file should be present at this path for riscof to verify at the end of testing.
    * - ``${macros}``
      - The macros to be defined while compilation. Currently they are in the format expected by gcc i.e. ``-D <macro-name>=<macro-value>``

**Example**:

The Makefile.include for the SAIL C Simulator from 
`here <https://github.com/riscv/riscv-arch-test/blob/2.4.4/riscv-target/sail-riscv-c/device/rv32i_m/I/Makefile.include>`_ 
is used as a reference for this example.

.. code-block:: Makefile
    :linenos:    

    TARGET_SIM   ?= riscv_sim_RV32 -V
    TARGET_FLAGS ?= $(RISCV_TARGET_FLAGS)
    ifeq ($(shell command -v $(TARGET_SIM) 2> /dev/null),)
        $(error Target simulator executable '$(TARGET_SIM)` not found)
    endif
    
    RUN_CMD=\
        $(TARGET_SIM) $(TARGET_FLAGS) \
            --test-signature=$(*).signature.output \
            $(<) 
    
    RISCV_PREFIX   ?= riscv32-unknown-elf-
    RISCV_GCC      ?= $(RISCV_PREFIX)gcc
    RISCV_OBJDUMP  ?= $(RISCV_PREFIX)objdump
    RISCV_GCC_OPTS ?= -g -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles $(RVTEST_DEFINES)
    
    COMPILE_CMD = $$(RISCV_GCC) $(1) $$(RISCV_GCC_OPTS) \
    							-I$(ROOTDIR)/riscv-test-suite/env/ \
    							-I$(TARGETDIR)/$(RISCV_TARGET)/ \
    							-T$(TARGETDIR)/$(RISCV_TARGET)/link.ld \
    							$$(<) -o $$@ 
    OBJ_CMD = $$(RISCV_OBJDUMP) $$@ -D > $$@.objdump; \
    					$$(RISCV_OBJDUMP) $$@ --source > $$@.debug
    
    
    COMPILE_TARGET=\
    				$(COMPILE_CMD); \
            if [ $$$$? -ne 0 ] ; \
                    then \
                    echo "\e[31m$$(RISCV_GCC) failed for target $$(@) \e[39m" ; \
                    exit 1 ; \
                    fi ; \
    				$(OBJ_CMD); \
            if [ $$$$? -ne 0 ] ; \
                    then \
                    echo "\e[31m $$(RISCV_OBJDUMP) failed for target $$(@) \e[39m" ; \
                    exit 1 ; \
                    fi ;
    
    RUN_TARGET=\
    	$(RUN_CMD) 

The first order of business is to move the ``COMPILE_CMD`` and ``RUN_CMD`` and define the contents
in the ``COMPILE_TARGET`` and ``RUN_TARGET`` respectively as these are the only commands where the
values will be substituted by the python function. Hence the respective variables look like this:

.. code-block:: Makefile
    :linenos:    

    COMPILE_CMD = $$(RISCV_GCC) $(1) $$(RISCV_GCC_OPTS) \
    							-I$(ROOTDIR)/riscv-test-suite/env/ \
    							-I$(TARGETDIR)/$(RISCV_TARGET)/ \
    							-T$(TARGETDIR)/$(RISCV_TARGET)/link.ld \
    							$$(<) -o $$@ 

    RUN_CMD=\
        $(TARGET_SIM) $(TARGET_FLAGS) \
            --test-signature=$(*).signature.output \
            $(<) 

Then these commands are rewritten to work with the python substitution variables. Hence variables
such as ``$$(<)`` are replaced with ``${asm}`` in compile and ``$test_bin`` in the run commands. The
``$$@`` in compile is replaced with ``${test_bin}``. This ensures that the binary file is
appropriately created. The values for ``march`` and ``mabi`` was defied in the old framework in the
makefiles for the suite. These values are provided per target in riscof. Hence the ``$(1)`` is
replaced with ``-march=${march} -mabi=${mabi}``. 

The directory with the header files for the tests is also provided by riscof. Hence line 2 is
replaced with ``-I${include} \``. The paths in lines 3 and 4 are fixed to the appropriate ones by
using the directory where the plugin file is present as an anchor. Riscof also provides macro
definitions for the tests too and the plugin generates these macros in the format required by gcc.
Hence ``${macro}`` is added to the end of the compile command.

Similarly the path to the signature file in line 9 is also replaced with ``${signature_file}`` to
ensure correct path. Since ``$(RVTEST_DEFINES)`` is no longer available, it is removed from
``RISCV_GCC_OPTS`` on line 15 in the first snippet. Finally, all conditional code is cleanned up and
the final makefile looks like this:

.. code-block:: Makefile
    :linenos:

    TARGET_SIM   ?= riscv_sim_RV32 -V
    TARGET_FLAGS =
    
    RISCV_PREFIX   ?= riscv32-unknown-elf-
    RISCV_GCC      ?= $(RISCV_PREFIX)gcc
    RISCV_OBJDUMP  ?= $(RISCV_PREFIX)objdump
    RISCV_GCC_OPTS ?= -g -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
    
    COMPILE_TARGET=\
                $$(RISCV_GCC) -march=${march} -mabi=${mabi} $$(RISCV_GCC_OPTS) \
    							-I${include} \
    							-I${target_dir}/env/ \
    							-T${target_dir}/env/link.ld \
    						    ${asm} -o ${test_bin} ${macros}
    
    RUN_TARGET=\
        $(TARGET_SIM) $(TARGET_FLAGS)\
            --test-signature=${signature_file} \
            ${test_bin} 

To add the disassembly of the test as an artifact of the run, the ``COMPILE_TARGET`` can be modified
to the following:

.. code-block:: Makefile
    :linenos:

    COMPILE_TARGET=\
                $$(RISCV_GCC) -march=${march} -mabi=${mabi} $$(RISCV_GCC_OPTS) \
    							-I${include} \
    							-I${target_dir}/env/ \
    							-T${target_dir}/env/link.ld \
    						    ${asm} -o ${test_bin} ${macros};\
            $$(RISCV_OBJDUMP) ${test_bin} -D > ${test_name}.disass; \
    					$$(RISCV_OBJDUMP) ${test_bin} --source > ${test_name}.debug

.. note::
    To ensure that a ``$`` is printed in the output Makefile (like ``$(RISCV_GCC)``) ensure that a
    ``$$`` is present in the input makefile.

Plugin Function Explanation
---------------------------

\_\_init\_\_(self, *args, **kwargs)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python
    :linenos:

    def __init__(self, *args, **kwargs):
        sclass = super().__init__(*args, **kwargs)

        # Get the node for the plugin in the config.ini file. This is extracted by riscof and only
        # the node relevant to the plugin is passed.
        config = kwargs.get('config')

        # Extract all information from the nodes. If any required values are missing, an error and a
        # system exit is raised.
        if 'makefiles' not in config:
            logger.error("Path to the Makefiles not specified for "+self.__model__)
            raise SystemExit
        if 'ispec' not in config or 'pspec' not in config:
            logger.error("Path to the input YAML files not specified for "+self.__model__)
            raise SystemExit
        # Paths to the Makefile.include files. Mandatory to be provided
        self.makefiles = [os.path.abspath(path) for path in config['makefiles'].split(",")]
        # Number of jobs to launch in parallel
        self.num_jobs = str(config['jobs'] if 'jobs' in config else 1)
        # Path to the directory in which this file is present
        self.pluginpath = os.path.dirname(__file__)
        # Path to the input ISA yaml as per riscv-config format.
        self.isa_spec = os.path.abspath(config['ispec']) if 'ispec' in config else ''
        # Path to the input platform yaml as per riscv-config format.
        self.platform_spec = os.path.abspath(config['pspec']) if 'ispec' in config else ''
        self.make = config['make'] if 'make' in config else 'make'
        return sclass

This function extracts the necessary fields from the node for the plugin in the config file given to
riscof. The plugin supports the following arguments.
    - **makefiles** (*required*)- Comma separated paths to the makefiles. If multiple are specified, all will be
      merged in the final output makefile. Note that only the varaibles in the makefiles are written
      out into the final makefiles. Any targets or includes will be left out. Such cases can be
      handled by editing the plugin to output the relevant lines as a part of the ``build`` function.
    - **ispec** (*required*)- The path to the input ISA yaml specification of the target.
    - **pspec** (*required*)- The path to the input platform yaml specification of the target.
    - **make** - The make utility to use like make,bmake,pmake etc. (Default is ``make``)
    - **jobs** - The number of threads to launch parallely. (Default is ``1``)

initialise(self, suite, work_dir, archtest_env)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python
    :linenos:

    def initialise(self, suite, work_dir, archtest_env):
        # Store the path to the suite.
        self.suite = suite
        # Store the path to the root level work directory.
        self.work_dir = work_dir
        # Store the path to the folder which contains the header files for the tests.
        self.archtest_env = archtest_env

This function stores the necessary values as variables local to the instance.


build(self, isa_yaml, platform_yaml)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python
    :linenos:

    def build(self, isa_yaml, platform_yaml):
        # Extract the configuration of hart0 from isa yaml to figure out the configuration of the
        # hart being tested.
        ispec = utils.load_yaml(isa_yaml)['hart0']
        # Resolve xlen value from the isa yaml
        self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')
        # Store the ISA of the target.
        self.isa = ispec["ISA"]
        self.var_dict = {}
        # Extract all variables from the makefiles
        for fpath in self.makefiles:
            self.var_dict.update(getmakevars(fpath))
        # The path where the Makefile is created
        self.makefilepath = os.path.join(self.work_dir, "Makefile." + self.name[:-1])
        with open(self.makefilepath,"w") as fp:
            # The path to the target directory, i.e the directory where this python file is
            # present. This variable is written out to the makefile so that other variables can use
            # this value.
            fp.write("TARGET_DIR = "+self.pluginpath+"\n")
            # Write out all values except the COMPILE_TARGET and RUN_TARGET commands
            for entry in self.var_dict.keys():
                if not entry.endswith("_TARGET"):
                    fp.write(entry+" = "+self.var_dict[entry]+"\n")
                else:
                    self.var_dict[entry] = Template(self.var_dict[entry])

This function extracts and resolves the values of different fields needed while generating compile
commands. Line 8, the ISA of the model is extracted from the input ISA yaml. Lines 11 and 12
extract all variables from the input makefiles. Line 14 generates the absolute path for the
makefile. The rest of the lines write out all the variables except the ones named ``*_TARGET`` to 
the output makefile. Line 19 writes out an extra variable ``TARGET_DIR`` which points to the
directory where the plugin files exist. This variable can be used as an anchor to resolve paths to
other necessary files (like linker scripts) in the commands.


runTests(self, testList,cgf_file=None)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python
    :linenos:

    def runTests(self, testList,cgf_file=None):
        # Initialise the Make Utility from riscof with the output path for the Makefile
        make = utils.makeUtil(makefilePath=self.makefilepath)
        # Modify the make command based on the input values in the config file.
        make.makeCommand = self.make + ' -j' + self.num_jobs
        # Iterate over all the entries in the test list
        for entry in testList:
            # Extract the entry from the testlist
            testentry = testList[entry]
            # Extract the path to the assembly test file from the test list entry
            test = testentry['test_path']
            # Extract the path to the work directory for the test.
            test_dir = testentry['work_dir']
            # Macros to be defined are added in the GCC command format
            # -D <macro_name>=<macro_value>
            # Change this if the toolchain uses a different format
            macros = ' -D' + " -D".join(testentry['macros'])
            # Variables accessible in the *_TARGET commands
            # Add more variables below if you wish to use these variables in the *_TARGET commands.
            substitute = {
                # The path to the target directory, i.e the directory where this python file is
                # present
                'target_dir': self.pluginpath,
                # Path to the test assembly file
                'asm': test,
                # Path to the work directory
                'work_dir': testentry['work_dir'],
                # Name of the Test. Can be used to name files in the work directory.
                'test_name': test.rsplit('/',1)[1][:-2],
                # The path to the env folder containing the header files for the suite. This path
                # should be passed as an include path in the compile commands.
                'include': self.archtest_env,
                # The isa string to be passed to the compiler. The format adheres to the march
                # argument of GCC
                'march': testentry['isa'].lower(),
                # The abi string to be passed to the compiler. The format adheres to the mabi
                # argument of GCC. To change how this string is derived, change function on line 21.
                'mabi': mabi(testentry['isa']),
                # The ISA string present in the input yaml. Can be used to set the ISA of the target
                'target_isa': self.isa,
                # Name of the generated binary file. Can be custom.
                'test_bin': 'ref.elf',
                # Name of the signature file. Note the name of the file should be in the same
                # particular format and inside the test work directory.
                'signature_file': os.path.join(test_dir, self.name[:-1] + ".signature"),
                # The string which specifies all the macros to be defined for the test. As computed
                # in line 108.
                'macros': macros
            }

            # Construct the command for the test and add a target in the makefile. The format of the
            # command is as follows:
            # cd <work_directory>;substitute(COMPILE_TARGET);substitute(RUN_TARGET);
            # The RUN_TARGET is optional and can be skipped if the same is not defined in the input
            # makefile
            execute = "@cd "+testentry['work_dir']+";"

            compile_cmd = self.var_dict['COMPILE_TARGET'].safe_substitute(substitute)
            execute+=compile_cmd+";"
            if 'RUN_TARGET' in self.var_dict:
                run_cmd = self.var_dict['RUN_TARGET'].safe_substitute(substitute)
                execute+=run_cmd+";"
            # Add target in the makefile for the test
            make.add_target(execute,)
        # Execute all targets.
        make.execute_all(self.work_dir)

This function uses the ``makeUtil`` provided by ``riscof.utils`` to write out a Makefile with the
commands for each entry in the testlist. The format of the command for each target is 
``cd <work_directory>;substitute(COMPILE_TARGET);substitute(RUN_TARGET);``. Lines 9 to 49 extract 
and setup the values of the necessary variables for substitution. This function uses the `template 
substitution <https://docs.python.org/3/library/string.html#template-strings>`_ provided by the 
``string`` class of python. The values of the variables in the template strings are defined in a
dictionary(``substitute``) and the substitution is performed for the ``COMPILE_TARGET`` on line 58.
Similarly if ``RUN_TARGET`` is defined in the input makefile, the substitution for the same is done
on line 61. Finally the target is added to the makefile and all targets are executed.


Tips
====

1. Avoid writing out multiple ``;`` simultaneously in the Makefiles.
2. Use the template substitution provided by the ``string`` class in python instead of string
   operations to ease command generation and avoid formatting errors. `This <https://askpython.com/python/string/python-template-strings>`_ article provides a good
   overview on the same.
3. It is advisable to use the ``logger`` provided by ``riscof.utils`` for logging/printing
   information to the console.
4. Ensure to add space between multiple arguments in a command to avoid execution errors.

   .. code-block:: python

        ## Avoid this. The generated command is wrong and will cause an execution error due to a
        ## missing space before -T
        execute += 'riscv64-unknown-elf-gcc'+'-T bin/link.ld'


Other Utilities available
=========================

RISCOF also provides various standard and quick utilities that can be used by the plugins

logger
------

This utility is used for colored and prioritized printing on the terminal. It provides the following
levels (in increasing order)

1. ``logger.debug(<string>)``: Blue color
2. ``logger.info(<string>)``: Green color
3. ``logger.error(<string>)``: Red color

Usage:

.. code-block:: python

  logger.debug('Performing Compile')

Other utilities
---------------

More utilities like makeUtil and shellcommand execution are available to the users. Details can be
found here: :ref:`utils`
