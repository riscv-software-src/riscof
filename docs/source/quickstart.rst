Quickstart
----------

Install dependencies
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    sudo apt-get install python3 pip3 # make sure to use python3.7 or above
    git clone https://gitlab.com/incoresemi/riscof.git
    python setup.py install

Usage
^^^^^

.. code-block:: bash

    python -m riscof.main -h
    usage: riscof [-h] [--dut_model MODEL] [--dut_env_file FILE]
                  [--base_model MODEL] [--base_env_file FILE] --dut_isa_spec YAML
                  --dut_platform_spec YAML [--dut_env_yaml YAML] [--verbose]

    This program checks compliance for a DUT.

    optional arguments:
      --base_env_file FILE, -bf FILE
                            The FILE for Base model containing necessary
                            environment parameters.
      --base_model MODEL, -bm MODEL
                            The MODEL whose against which the compliance is
                            verified.
      --dut_env_file FILE, -df FILE
                            The FILE for DUT containing necessary environment
                            parameters.
      --dut_env_yaml YAML, -eyaml YAML
                            The YAML which contains the Platfrorm specs of the
                            DUT.
      --dut_isa_spec YAML, -ispec YAML
                            The YAML which contains the ISA specs of the DUT.
      --dut_model MODEL, -dm MODEL
                            The MODEL whose compliance is to be verified.
      --dut_platform_spec YAML, -pspec YAML
                            The YAML which contains the Platfrorm specs of the
                            DUT.
      --verbose             debug | info | warning | error
      -h, --help            show this help message and exit

Example:


This Example runs spike vs spike. Please ensure spike and riscv toolchain is installed and configured before running this.

.. code-block:: bash

    python -m riscof.main \
    -bm model_from_yaml \
    -bf Examples/template_env.yaml \
    -eyaml Examples/template_env.yaml \
    -dm model_from_yaml \
    -ispec Examples/rv32i_isa.yaml \
    -pspec Examples/rv32i_platform.yaml \
    --verbose debug


