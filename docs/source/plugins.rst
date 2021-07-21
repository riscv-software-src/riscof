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

The ``env`` folder can also contain other necessary plugin specific files for pre/post processing of
logs, signatures, elfs, etc.

The yaml specs in the DUT plugin directory are the most important inputs to the RISCOF framework.
All decisions of filtering tests depend on the these YAML files. The files must follow the
syntax/format specified by `riscv-config <https://github.com/riscv/riscv-config>`_. These YAMLs are
validated in RISCOF using riscv-config. 

The python plugin files capture the behavior of model for compiling tests, executing them on the DUT
and finally extracting the signature for each test. The following sections provide a detailed
explanation on how to build the python files for your model.


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

Start with Templates
====================

A sample template of the plugin and all other required collateral can be generated through RISCOF
using the following command::

  $ riscof setup --refname=sail_cSim --dutname=spike

.. note:: You can change the name from spike to the name of your target

This above command should generate a spike folder with the following contents:

.. code-block:: bash

  env                          # contains sample header file and linker file   
  riscof_spike.py              # sample spike plugin for RISCOF
  spike_isa.yaml               # sample ISA YAML configuration file
  spike_platform.yaml          # sample PLATFORM YAML configuration file

The command will also generate a sample ``config.ini`` file with the following contents:

.. code-block:: bash

  [RISCOF]
  ReferencePlugin=cSail                                                                               
  ReferencePluginPath=/scratch/git-repo/incoresemi/riscof/sail_cSim
  DUTPlugin=spike
  DUTPluginPath=/scratch/git-repo/incoresemi/riscof/spike
  
  [spike]
  pluginpath=/scratch/git-repo/incoresemi/riscof/spike
  ispec=/scratch/git-repo/incoresemi/riscof/spike/spike_isa.yaml                                 
  pspec=/scratch/git-repo/incoresemi/riscof/spike/spike_platform.yaml
  
  [sail_cSim]
  pluginpath=/scratch/git-repo/incoresemi/riscof/sail_cSim

The following changes need to be made:

1. Fix the paths in the ``config.ini`` to point to the folder containing the respective riscof_*.py files.
2. The macros in the ``spike/env/model_test.h`` can be updated based on the model. Definitions of
   the macros and their use is available in the :ref:`test_format_spec`.
3. Update the ``riscof_<target-name>.py`` with respective functions as described in the following 
   paragraphs.

The plugin file in the ``spike`` folder: riscof_spike.py is the one that needs to be
changed and updated for each model as described in the next section.


Please note the user is free to add more custom functions in this file which are called within the
three base functions (as mentioned above).

.. _plugin_def:

Plugin Function Definitions
===========================

As can be seen from the template python file, it creates a Metaclass for the plugins 
supported by the :ref:`abstract_class`. This class basically offers the users three basic 
functions: ``initialize`` , ``build`` and ``runTests``. 
For each model RISCOF calls these functions in the following order:

.. code-block:: bash

  initialize --> build --> runTests

We now define the various arguments and expected functionality of each of the above
mentioned functions. Please note, this is not a strict guide and the users can choose to perform
different actions in different functions as opposed to what is outlined in this guide as long as
they comply with the order of the functions being called and the signatures are generated in their 
respective directories at the end of the `runTest` function.

__init__ (self, *args, **kwargs)
--------------------------------

This is the constructor function for the pluginTemplate class. The configuration dictionary of the
plugin, as specified in the ``config.ini``, is passed to the plugin via the kwargs argument.

In this function you will also need to define the path of the model executable in the `dut_exe`
variable as shown in line-6 below. Note, this variable can be dierctly set in the ``config.ini`` by
setting the `PATH` variable under the model plugin's header.

The `num_jobs` variable, in line-7,  is used to indicate the number of parallel jobs that can be
spawned for simulation.

Finally, thise constructor will capture the paths to the plugin, the isa yaml and the platform yaml
for further usage (as seen in lines 13-14).

.. code-block:: python
    :linenos:

    def __init__(self, *args, **kwargs):
        sclass = super().__init__(*args, **kwargs)

        config = kwargs.get('config')

        self.dut_exe = os.path.join(config['PATH'] if 'PATH' in config else "","spike")
        self.num_jobs = str(config['jobs'] if 'jobs' in config else 1)
        if config is None:
            print("Please enter input file paths in configuration.")
            raise SystemExit
        else:
            self.isa_spec = os.path.abspath(config['ispec'])
            self.platform_spec = os.path.abspath(config['pspec'])
            self.pluginpath=os.path.abspath(config['pluginpath'])

        return sclass

.. warning:: if the config is empty or if the isa and platform yamls are not available in the
   specified paths, the above function shall generate an error and exit.


initialize (suite, workdir, env)
--------------------------------

This function is typically meant to create and initialize all necessary variables such as :
compilation commands, elf2hex utility command, objdump command, include directories, etc.
This function provides the following arguments which can be used:

1. `suite`: This argument holds the absolute path of the directory where the architectural test suite
   exists.This can be used to replace the name of the file to create directories in proper order.
2. `workdir`: This argument holds the absolute path of the work directory where all the execution
   and meta files/states will be dumped as part of running RISCOF.
3. `archtest_env`: This argument holds the absolute path of the directory where all the
   architectural test header files are located. This should be used to initialize the include arguments to the
   compiler/assembler.

An example of this function is shown below:

.. code-block:: python
   :linenos:

   def initialise(self, suite, work_dir, archtest_env):
       if shutil.which(self.dut_exe) is None:
           logger.error(self.dut_exe+' Not Found')
           logger.error('Please install Executable for spike to proceed further')
           sys.exit(0)
       self.work_dir = work_dir

       #TODO: The following assumes you are using the riscv-gcc toolchain. If
       #      not please change appropriately
       self.compile_cmd = 'riscv{1}-unknown-elf-gcc -march={0} \
        -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles\
        -T '+self.pluginpath+'/env/link.ld\
        -I '+self.pluginpath+'/env/\
        -I ' + archtest_env

       # set all the necessary variables like compile command, elf2hex
       # commands, objdump cmds. etc whichever you feel necessary and required
       # for your plugin. 

The `dut_exe` variable in line-2 above, is derived and set in the `__init__` function described
earlier. This function checks if the `dut_exe` is indeed available and throws an error if not. The
above template is used for the riscv-gnu-toolchain. If you are using an alternate or custom
toolchain the `compile_cmd`, in line-10 above, will have  to be changed appropriately.

One can also choose to add moer commands like objdump, elf2hex, etc from line 202 onwards which will
be used further during the build and run phases.

build(isa_yaml, platform_yaml)
------------------------------

RISCOF is not limited to validating only a RTL targets, but can also be used to validate
instruction set simulators (ISS) or modern day core-generators like rocket or chromite. These ISS
and core generators have the ability to tune themselves to a specific set of configurations as defined in
the standardized RISCV-CONFIG YAML. Thus, the `build` phase can be used as an intermediate stage to
build or configure not only these models/targets but also be used to build respective custom tool-chains that may be required.

The `build` function provides the following arguments:

1. `isa_spec`: This argument holds the path to the validated ISA config YAML. This can be used to extract
   various fields from the YAML (e.g. ISA) and configure the DUT accordingly.
2. `platform_spec`: This argument holds the path to the validated PLATFORM config YAML and can be used
   similarly as above.

An example of this function for an ISS like spike is show below:

.. code-block:: python
   :linenos:

   def build(self, isa_spec, platform_spec):
      ispec = utils.load_yaml(isa_yaml)['hart0']
      self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')
      self.isa = 'rv' + self.xlen
      #TODO: The following assumes you are using the riscv-gcc toolchain. If
      #      not please change appropriately
      self.compile_cmd = self.compile_cmd+' -mabi='+('lp64 ' if 64 in ispec['supported_xlen'] else 'ilp32 ')
      if "I" in ispec["ISA"]:
          self.isa += 'i'
      if "M" in ispec["ISA"]:
          self.isa += 'm'
      if "C" in ispec["ISA"]:
          self.isa += 'c'

      # based on the validated isa and platform configure your simulator or
      # build your RTL here

.. note:: For RTL targets this phase is typically empty and no actions are required. Though, one
   could choose to compile the RTL in this phase if required.

runTests(testlist)
------------------

This function is responsible for executing/running each test on the mode and produce individual
signature files. A common approach is to create a simple Makefile with each test as a target using
the commands and initializations done during the build and initialization phase. RISCOF also
provides a simple `makeUtil` utility function which can be used directly, however, users are free to
define their own execution environments. After generating the Makefile, the users should also
call the ``make`` or suitable command to execute the run.

The function takes a single argument: `testlist` which is a dictionary of tests and respective meta
informations. The format of the testlist is available here: :ref:`testlist`.

At the end of execution of this function it is expected that each test has a signature file available 
in the respective work_dir. The signature file generated should be named : ``self.name[:-1].+"signature"``

A sample of this function which uses the ``shellCommand`` utility for compiling, executing and
renaming the signature file. The function essentially iterates over all the tests in a sequence
performing the same commands.


.. code-block:: python
  :linenos:

  def runTests(self, testList):
      for file in testList:
          testentry = testList[file]
          test = testentry['test_path']
          test_dir = testentry['work_dir']

          elf = 'my.elf'
          sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")

          cmd = self.compile_cmd.format(testentry['isa'].lower(), self.xlen) + ' ' + test + ' -o ' + elf
          compile_cmd = cmd + ' -D' + " -D".join(testentry['macros'])
          logger.debug('Compiling test: ' + test)
          utils.shellCommand(compile_cmd).run(cwd=test_dir)

          execute = spike_path + 'spike --isa={0} +signature={1} +signature-granularity=4 {2}'.format(self.isa, sig_file, elf)
          logger.debug('Executing on Spike ' + execute)
          utils.shellCommand(execute).run(cwd=test_dir)

An example which uses the ``makeUtil`` utility is show below. Here a Makefile is first generated
where every test is a make target. the utility automatically creates the relevant targets and only
requires the user to define what should occur under each target.

The user can choose to use a different make command by setting
the ``make.makeCommand``. More details of this utility are available at: :ref:`utils`

.. code-block:: bash
  :linenos:

  def runTests(self, testList):
      make = utils.makeUtil(makefilePath=os.path.join(self.work_dir, "Makefile." + self.name[:-1]))
      make.makeCommand = 'make -j' + self.num_jobs
      for file in testList:
          testentry = testList[file]
          test = testentry['test_path']
          test_dir = testentry['work_dir']

          elf = 'dut.elf'
          
          execute = "@cd "+testentry['work_dir']+";"

          cmd = self.compile_cmd.format(testentry['isa'].lower(), self.xlen) + ' ' + test + ' -o ' + elf

          #TODO: we are using -D to enable compile time macros. If your
          #      toolchain is not riscv-gcc you may want to change the below code
          compile_cmd = cmd + ' -D' + " -D".join(testentry['macros'])
          execute+=compile_cmd+";"

          sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")

          #TODO: You will need to add any other arguments to your DUT
          #      executable if any in the quotes below
          execute += self.dut_exe + ' --log-commits --log dump --isa={0} +signature={1} +signature-granularity=4 {2};'.format(self.isa, sig_file, elf)

          make.add_target(execute)
      make.execute_all(self.work_dir)

.. include:: ../../PLUGINS.rst


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
