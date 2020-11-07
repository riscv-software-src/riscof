.. _plugins:

.. highlight:: shell


########################
Create your Model Plugin
########################

RISCOF requires python plugins for each model (DUT and Reference) to be submitted. These plugins
provide a quick and standard way of building any model, compiling any/all the tests and
executing the tests on the models. 

Why Python Plugins ?
====================

Since the entire RISCOF framework is in python it did not make sense to have the 
user-DUT in a separate environment. It would then cause issues in transferring data across 
these environments/domains. 

While many prefer the conventional *Makefile/autoconf* approach, transfering the *test-list* in YAML 
to be used by another Makefile-environment seemed like a bad and an unscalable idea.

Expecting initial hesitation, we have tried to ensure that the python plugins can be made extremely 
simple (as crude as writing out bash instructions using shellCommand libraries). 

Considering there would be a few backlashes in these choices, we have given enough pit-stops in the 
flow: ``validation, test-list, coverage, etc`` so one can stop at any point in the flow and move 
to their custom domain. 

If you do feel the flow can be further improved or changed please do drop in an issue on the
official repository.

Generate Templates
==================

A sample template of the plugin and all other required collaterals can be generated through RISCOF
using the following command::

  $ riscof setup --refname=sail_cSim --dutname=spike_simple

.. note:: You can change the name from spike_simple to the name of your target

This above command should generate a spike_simple folder with the following contents:

.. code-block:: bash

  env                                 # contains sample header file and linker file   
  riscof_spike_simple.py              # sample spike plugin for RISCOF
  spike_simple_isa.yaml               # sample ISA YAML configuration file
  spike_simple_platform.yaml          # sample PLATFORM YAML configuration file

The command will also generate a sample ``config.ini`` file with the following contents:

.. code-block:: bash

  [RISCOF]
  ReferencePlugin=cSail                                                                               
  ReferencePluginPath=/scratch/git-repo/incoresemi/riscof/sail_cSim
  DUTPlugin=spike_simple
  DUTPluginPath=/scratch/git-repo/incoresemi/riscof/spike_simple
  
  [spike_simple]
  pluginpath=/scratch/git-repo/incoresemi/riscof/spike_simple
  ispec=/scratch/git-repo/incoresemi/riscof/spike_simple/spike_simple_isa.yaml                                 
  pspec=/scratch/git-repo/incoresemi/riscof/spike_simple/spike_simple_platform.yaml

The following changes need to be made:

1. Fix the paths in the ``config.ini`` to point to the folder containing the respective riscof_*.py files.
2. The macros in the ``spike_simple/env/compliance_model.h`` can be updated based on the model. Definitions of
   the macros and their use is available in the :ref:`test_format_spec`.
3. Update the ``riscof_<target-name>.py`` with respective functions as described in the following 
   paragraphs.

The plugin file in the ``spike_simple`` folder: riscof_spike_simple.py is the one that needs to be
changed and updated for each model. As can be seen from this python file, it creates a Metaclass for the plugins 
supported by the abstract base class. This class basically offers the users three basic 
functions: ``initialize`` , ``build`` and ``runTests``. For each model RISCOF calls these functions in the following order:

.. code-block:: bash

  initialize --> build --> runTests

Please note the user is free to add more custom functions in this file which are called within the
three base functions (as mentioned above).

Config.ini Syntax
=================

The ``config.ini`` file generated using the above ``--setup`` command is used by RISCOF to locate the DUT and Reference
plugins (along with their necessary collaterals). The config file also allows you to define specific nodes/fields
which can be used by the respective plugin. For e.g., in the default ``config.ini`` template the
`pluginpath` variable under the `[spike_simple]` header is available to the riscof_spike_simple.py
plugins by RISCOF. Similarly one can define more variables and prefixes here which can directly be
used in the plugins. 

The idea here is to have a single place of change which is easy rather than hard-coding the same
within the plugins.

Function Definitions
====================

We now define the various arguments and expected functionality of each of the above
mentioned functions. Please note, this is not strict guide and the users can choose to perform
different actions in different functions as opposed to what is outlined in this guide as long as
they comply with the order of the functions being called and the signatures are generated in their 
respective directories at the end of the `runTest` function.

initialize (suite, workdir, env)
--------------------------------

This function is typically meant to create and initialize all necessary variables such as :
compilation commands, elf2hex utility command, objdump command, include directories, etc.
This function provides the following arguments which can be used:

1. `suite`: This argument holds the absolute path of the directory where the compliance suite
   exists.This can be used to replace the name of the file to create directories in proper order.
2. `workdir`: This argument holds the absolute path of the work directory where all the execution
   and meta files/states will be dumped as part of running RISCOF.
3. `compliance_env`: This argument holds the absolute path of the directory where all the compliance header
   files are located. This should be used to initialize the include arguments to the
   compiler/assembler.

An example of this function is shown below:

.. code-block:: python

  def initialise(self, suite, work_dir, compliance_env):
      if shutil.which('spike') is None:
          logger.error('Please install spike to proceed further')
          sys.exit(0)
      self.work_dir = work_dir
      self.compile_cmd = 'riscv{1}-unknown-elf-gcc -march={0} \
       -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles\
       -T '+self.pluginpath+'/env/link.ld\
       -I '+self.pluginpath+'/env/\
       -I ' + compliance_env

build(isa_yaml, platform_yaml)
------------------------------

RISCOF is not limited to validating only a RTL targets, but can also be used to validate
instruction set simulators (ISS) or modern day core-generators like rocket or chromite. These ISS
and core generators have to ability to tune themselves to a specific set of options as defined in
the standardized RISCV-CONFIG YAML. Thus the `build` phase can be used as an intermediate stage to
build or configure not only these models/targets but also be used to build respective toolchains.

The `build` function provides the following arguments:

1. `isa_spec`: This argument holds the path to the ISA config YAML. This can be used to extract
   various fields from the YAML (e.g. ISA) and configure the DUT accordingly.
2. `platform_spec`: This argument holds the path to the PLATFORM config YAML and can be used
   similarly as above.

An example of this function for an ISS like spike is show below:

.. code-block:: python

  def build(self, isa_spec, platform_spec):
    ispec = utils.load_yaml(isa_yaml)['hart0']
    self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')
    self.isa = 'rv' + self.xlen
    self.compile_cmd = self.compile_cmd+' -mabi='+('lp64 ' if 64 in ispec['supported_xlen'] else 'ilp32 ')
    if "I" in ispec["ISA"]:
        self.isa += 'i'
    if "M" in ispec["ISA"]:
        self.isa += 'm'
    if "C" in ispec["ISA"]:
        self.isa += 'c'

.. note:: For RTL targets this phase is typically empty and no actions are required. Though, one
   could choose to compile the RTL in this phase if required.

runTests(testlist)
------------------

This function is responsible for executing/running each test on the mode and produce individual
signature files. A common approach is to create a simple Makefile with each test as a target using
the commands and initializations done during the build and initialization phase. RISCOF also
provides a simple `makeUtil` utility function which can be used directly, however, users are free to
define their own execution environments. After the generating the Makefile, the users should also
call the ``make`` or suitable command to execute the run.

The function takes a single argument: `testlist` which is a dictionary of tests and respective meta
informations. The format of the testlist is available here: :ref:`testlist`.

At the end of execution of this function it is expected that each test has a signature file available 
in the respective work_dir. The signature file generated should be named : ``self.name[:-1].+"signature"``

A sample of this function which uses the ``shellCommand`` utility for compiling, executing and
renaming the signature file. The function essentially iterates over all the tests in a sequence
performing the same commands.


.. code-block:: python

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

  def runTests(self, testList):
      make = utils.makeUtil(makefilePath=os.path.join(self.work_dir, "Makefile." + self.name[:-1]))
      make.makeCommand = 'make -j' + parallel_jobs
      for file in testList:
          testentry = testList[file]
          test = testentry['test_path']
          test_dir = testentry['work_dir']

          elf = 'my.elf'

          execute = "cd "+testentry['work_dir']+";"

          cmd = self.compile_cmd.format(testentry['isa'].lower(), self.xlen) + ' ' + test + ' -o ' + elf
          compile_cmd = cmd + ' -D' + " -D".join(testentry['macros'])
          execute+=compile_cmd+";"

          sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")
          execute += spike_path + 'spike --isa={0} +signature={1} +signature-granularity=4 {2};'.format(self.isa, sig_file, elf)

          make.add_target(execute)
      make.execute_all(self.work_dir)

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
