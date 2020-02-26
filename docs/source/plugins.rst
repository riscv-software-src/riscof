.. _plugins:

########################
Create your Model Plugin
########################

RISCOF requires python plugins for each model (DUT and Golden) to be submitted. These plugins
provide a quick and standard way of building any model, compiling any/all the tests and
executing the tests on the models. 

Generate Templates
------------------

A sample template of the plugin and all other required collaterals can be generated through RISCOF
using the following command :

.. code-block:: bash

  riscof --setup --refname=riscvOVPsim --dutname=spike_simple

This above command should generate a spike_simple folder with the following contents:

.. code-block:: bash

  env                                 # contains the header file and linker file   
  riscof_spike_simple.py              # spike plugin for RISCOF
  spike_simple_isa.yaml               # ISA YAML configuration fle
  spike_simple_platform.yaml          # PLATFORM YAML configuration file

The command will also generate a ``config.ini`` file with the following contents:

.. code-block:: bash

  [RISCOF]
  ReferencePlugin=riscvOVPsim
  ReferencePluginPath=/scratch/git-repo/incoresemi/riscof/riscvOVPsim
  DUTPlugin=spike_simple
  DUTPluginPath=/scratch/git-repo/incoresemi/riscof/spike_simple
  
  [spike_simple]
  pluginpath=/scratch/git-repo/incoresemi/riscof/spike_simple
  ispec=/scratch/git-repo/incoresemi/riscof/spike_simple/spike_simple_isa.yaml                                 
  pspec=/scratch/git-repo/incoresemi/riscof/spike_simple/spike_simple_platform.yaml

Post running the ``--setup`` command the user needs to make the following changes for:

1. Fix the paths in the ``config.ini`` to point to the folder containing the respective riscof_*.py files.
2. The macros in the ``spike_simple/env/compliance_model.h`` can be updated based on the model. Definitions of
   the macros and their use is available in the `Test-Format-Spec <https://github.com/allenjbaum/riscv-compliance/blob/master/spec/TestFormatSpec.pdf>`_.
3. Update the ``riscof_<dutname>.py`` with respective functions as described in the following 
   paragraphs.

The plugin file in the ``spike_simple`` folder: riscof_spike_simple.py is the one that needs to be
defined for each model. As can be seen from this python file, it creates a Metaclass for the plugins 
supported by the abstract base class. This class basically offers the users thre basic 
functions: ``initialize`` , ``build`` and ``runTests``. For each model RISCOF calls these functions in the following order:

.. code-block:: bash

  initialize --> build --> runTests

Please note the user is free to add more custom functions in this file which are called within the
three base functions (as mentioned above).

Config.ini Syntax
-----------------

The config.ini file generate using the above command is used by RISCOF to locate the DUT and Golden
plugins and necessary collaterals. The config file also allows you to define specific nodes/fields
which can be used by the respective plugin. For e.g., in the default config.ini template the
`pluginpath` variable under the `[spike_simple]` header is available to the riscof_spike_simple.py
plugins by RISCOF. Similarly one can define more variables and prefixes here which can directly be
used in the plugins. 

The idea here is to have a single place of change which is easy rather than hard-coding the same
within the plugins

Function Definitions
--------------------

We now define what are the various arguments and expected functionality of each of the above
mentioned functions. Please note, this is not strict guide and the users can choose to perform
different actions in different functions as opposed to what is outlined in this guide as long as
they comply with the order of the functions being called and the signatures are generated in their respective directories at the end of the runTest function.

initialize (suite, workdir, env)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This function is typically meant to create and initialize all necessary variables such as :
compilation commands, elf2hex utility command, objdump command, include directories, etc.
This function provides the following arguments which can be used:

1. `suite`: This argument holds the absolute path of the directory where the compliance suite
   exists.This can be used to replace the name of the file to create directories in proper order.
2. `workdir`: This argument holds the absolute path of the work directory where all the execution
   and meta files/states will be dumped as part of running RISCOF.
3. `env`; This argument holds the absolute path of the directory where all the compliance header
   files are located. This should be used to initialize the include arguments to the
   compiler/assembler.

An example of this function is shown below:

.. code-block:: python

  def initialise(self, suite, work_dir, compliance_env):
      if shutil.which('spike') is None:
          logger.error('Please install spike to proceed further')
          sys.exit(0)
      self.work_dir = work_dir
      self.compile_cmd = 'riscv32-unknown-elf-gcc -march={0} -mabi=ilp32 \
       -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles\
       -T '+self.pluginpath+'/env/link.ld\
       -I '+self.pluginpath+'/env/\
       -I ' + compliance_env



build(isa_yaml, platform_yaml)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This function is used to build the DUT model/target. This can involve actions such as configuring a
simulator or building an RTL executable. This function provides the following arguments which can be
used:

1. `isa_spec`: This argument holds the path to the ISA config YAML. This can be used to extract
   various fields from the YAML (e.g. ISA) and configure the DUT accordingly.
2. `platform_spec`: This argument holds the path to the PLATFORM config YAML and can be used
   similarly as above.

An example of this function is show below:

.. code-block:: python

  def build(self, isa_spec, platform_spec):
    ispec = utils.load_yaml(isa_spec)
    self.isa = ispec['ISA']

runTests(testlist)
^^^^^^^^^^^^^^^^^^

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
            test = os.path.join(constants.root, str(file))
            test_dir = testentry['work_dir']

            elf = 'my.elf'

            cmd = self.compile_cmd.format(testentry['isa'].lower()) + ' ' + test + ' -o ' + elf
            compile_cmd = cmd + ' -D' + " -D".join(testentry['macros'])
            logger.debug('Compiling test: ' + test)
            utils.shellCommand(compile_cmd).run(cwd=test_dir)

            execute = 'spike --isa={0} +signature=sign {1}'.format(self.isa, elf)
            logger.debug('Executing on Spike ' + execute)
            utils.shellCommand(execute).run(cwd=test_dir)

            sign_fix = 'sh '+self.pluginpath+'/env/sign_fix.sh'
            logger.debug('Fixing Signature format ' + execute)
            utils.shellCommand(sign_fix).run(cwd=test_dir)

            logger.debug('Renaming signature file')
            rename_sign = 'cat sign > ' + os.path.join(test_dir, self.name[:-1] + ".signature")
            utils.shellCommand(rename_sign).run(cwd=test_dir)

An example which uses the ``makeUtil`` utility is show below. Here a Makefile is first generated
where every test is a make target. the utility automatically creates the relevant targets and only
requires the user to define what should occur under each target.

The user can choose to use a different make command by setting
the ``make.makeCommand``. More details of this utility are available at: :ref:`utils`

.. code-block:: bash

  def runTests(self, testList):
      make = utils.makeUtil(makefilePath=os.path.join(self.work_dir, "Makefile." + self.name[:-1]))
      #make.makeCommand = 'make -j8'
      #make.makeCommand = 'pmake -j 8'
      for file in testList:
          testentry = testList[file]
          test = testentry['test_path']
          test_dir = testentry['work_dir']

          elf = 'my.elf'

          execute = "cd "+testentry['work_dir']+";"

          cmd = self.compile_cmd.format(testentry['isa'].lower()) + ' ' + test + ' -o ' + elf
          compile_cmd = cmd + ' -D' + " -D".join(testentry['macros'])
          execute+=compile_cmd+";"

          execute += 'spike --isa={0} +signature=sign {1};'.format(self.isa, elf)

          sign_fix = 'sh '+self.pluginpath+'/env/sign_fix.sh'
          execute+=sign_fix+";"

          rename_sign = 'cat sign > ' + os.path.join(test_dir, self.name[:-1] + ".signature")
          execute+=rename_sign+";"
          make.add_target(execute)
      make.execute_all(self.work_dir)

Other Utilities available
-------------------------

RISCOF also provides various standard and quick utilities that can be used by the plugins

logger
^^^^^^

This utility is used for colored and prioritized printing on the terminal. It provides the following
levels (in increasing order)

1. ``logger.debug(<string>)``: Blue color
2. ``logger.info(<string>)``: Green color
3. ``logger.error(<string>)``: Red color

Usage:

.. code-block:: python

  logger.debug('Performing Compile')

Other utilities
^^^^^^^^^^^^^^^

More utilities like makeUtil and shellcommand execution are available to the users. Details can be
found here: :ref:`utils`
