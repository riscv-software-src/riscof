Quickstart
----------

Installation and Setup
^^^^^^^^^^^^^^^^^^^^^^^
1. Install riscof

    .. code-block:: bash

        sudo apt-get install python3 pip3 # make sure to use python3.7 or above

    * Install using pip(For users):

    .. code-block:: bash

        pip3 install riscof


    * Clone from git(For developers):

    .. code-block:: bash

        git clone https://gitlab.com/incoresemi/riscof.git
        cd riscof
        pip install docs/requirements.txt
        python setup.py install -e

2. Setup Plugins

    * Clone the plugins from git.

    .. code-block:: bash

        git clone https://gitlab.com/incoresemi/riscof-plugins.git

    * Follow the steps given in the respective plugin folders to set them up.
    * Add the paths of the plugins you wish to use to the *PYTHONPATH* variable in your *.bashrc* or by using the *export* command.

Usage
^^^^^

* For users

.. code-block:: bash

    riscof [-h] --dut_model MODEL_NAME [--base_model MODEL_NAME]
                      [--verbose]

        This program checks compliance for a DUT.

        optional arguments:
          --base_model MODEL_NAME, -bm MODEL_NAME
                                The name of the model(MODEL_NAME) against which
                                compliance is to be verified.
          --dut_model MODEL_NAME, -dm MODEL_NAME
                                The name of the model(MODEL_NAME) whose compliance is
                                to be verified.
          --verbose             debug | info | warning | error
          -h, --help            show this help message and exit


* For developers

.. code-block:: bash

    cd riscof/

    python -m riscof.main -h
        usage: riscof [-h] --dut_model MODEL_NAME [--base_model MODEL_NAME]
                      [--verbose]

        This program checks compliance for a DUT.

        optional arguments:
          --base_model MODEL_NAME, -bm MODEL_NAME
                                The name of the model(MODEL_NAME) against which
                                compliance is to be verified.
          --dut_model MODEL_NAME, -dm MODEL_NAME
                                The name of the model(MODEL_NAME) whose compliance is
                                to be verified.
          --verbose             debug | info | warning | error
          -h, --help            show this help message and exit

Example:

This Example runs spike vs sigGen. Please ensure spike and riscv toolchain is installed and configured before running this.
When prompted,give the path to the *template_env.yaml* in the *riscof-plugins/yamlPlugin/Examples/* folder.

.. code-block:: bash

    riscof -bm sigGen -dm yamlPlugin

.. code-block:: bash

    python -m riscof.main \
    -bm sigGen \
    -dm yamlPlugin \

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

