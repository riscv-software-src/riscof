Quickstart
----------

Installation and Setup
^^^^^^^^^^^^^^^^^^^^^^^
1. Install riscof

    Before proceding further please ensure *pip* and *python* is installed and configured.

    You can check the python version by using 
    
    .. code-block:: bash

        python3 --version

    *Support exists for python versions > 3.7.0 only. Please ensure correct version before proceding further.*

    * Install using pip(For users-**WIP**):

    .. code-block:: bash

        pip3 install -r riscof


    * Clone from git(For developers):

    .. code-block:: bash

        git clone https://gitlab.com/incoresemi/riscof.git
        cd riscof
        pip3 install -r requirements.txt

2. Setup Plugins

    * Clone the plugins from git.

    .. code-block:: bash

        git clone https://gitlab.com/incoresemi/riscof-plugins.git

    * Follow the steps given in the respective plugin folders to set them up.
    * Add the paths of the plugins you wish to use to the *PYTHONPATH* variable in your *.bashrc* or by using the *export* command.

Usage
^^^^^

* For users-**WIP**

.. code-block:: bash

    riscof [-h] [--setup] [--run] [--verbose]

    This program checks compliance for a DUT.

    optional arguments:
      --run       Run riscof in current directory.
      --setup     Initiate setup for riscof.
      --verbose   debug | info | warning | error
      -h, --help  show this help message and exit



* For developers

.. code-block:: bash

    cd riscof/

    python3 -m riscof.main -h
        usage: [-h] [--setup] [--run] [--verbose]

        This program checks compliance for a DUT.

        optional arguments:
          --run       Run riscof in current directory.
          --setup     Initiate setup for riscof.
          --verbose   debug | info | warning | error
          -h, --help  show this help message and exit


Example
^^^^^^^

This Example runs spike vs sigGen. Please ensure spike and riscv toolchain is installed and configured before running this.

1. Setup

    * For users-**WIP**

    .. code-block:: bash

        riscof --setup

    * For developers

    .. code-block:: bash

        python3 -m riscof.main --setup

    A *config.ini* file and *env* directory will be created in the *pwd*.

2. Configure
    
    Modify the config.ini file as follows. The *env* directory can be ignored for now.

    .. code-block:: ini

        [RISCOF]
        ReferencePlugin=sigGen
        DUTPlugin=spike

        [spike]
        ispec=#/path_to_riscof_plugins/yamlPlugin/Examples/rv32i_isa.yaml
        pspec=#/path_to_riscof_plugins/yamlPlugin/Examples/rv32i_platform.yaml
    
    In the above block please edit the paths to point to the files appropriately. Other plugins can be used in the same way by changing the names in the nodes and the DUTPlugin argument.

3. Run

    * For users-**WIP**

    .. code-block:: bash

        riscof --run --verbose debug

    * For developers
    
    .. code-block:: bash

        python3 -m riscof.main --run --verbose debug



Writing your own Plugins
^^^^^^^^^^^^^^^^^^^^^^^^^
* Ensure that the module is named as *riscof_\*model_name\*.py* and the class is named as *model_name*.
* The class is a subclass of the *pluginTemplate* class present in *riscof.pluginTemplate*.
* The path where the file exists is present on the *PYTHONPATH*.

.. code-block:: python

    #riscof_sample.py
    from riscof.pluginTemplate import pluginTemplate
    class sample(pluginTemplate):
        def __init__(self,*args,**kwargs):
            super().__init__(*args,**kwargs)
            #Your code here
        
        def initialise(self,suite,workdir):
            super().initialise(suite,workdir)
            #Your code here
        
        def build(self,isa_spec,platform_spec):
            super().build(isa_spec,platform_spec)
            #Your code here
        
        def compile(self,file,macros,isa):
            super().compile(file,macros,isa)
            #Your code here
        
        def simulate(file);
            super().simulate(file)
            #Your code here

