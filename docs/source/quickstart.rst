Quickstart
----------

Install dependencies
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    sudo apt-get install python3 pip3 # make sure to use python3.5 or above
    git clone https://gitlab.com/incoresemi/riscof.git
    pip3 install -r requirements.txt

Usage
^^^^^

.. code-block:: bash

    python3 -m rips.main -h
    usage: RIPS Checker [-h] --input_isa YAML --input_platform YAML
                        [--input_environment YAML] --schema_isa YAML
                        --schema_platform YAML [--verbose]

    This Program checks an input YAML for compatibility with RIPS format

    optional arguments:
      --input_environment YAML, -ei YAML
                            Input YAML file containing environment specs.
      --input_isa YAML, -ii YAML
                            Input YAML file containing ISA specs.
      --input_platform YAML, -pi YAML
                            Input YAML file containing platform specs.
      --schema_isa YAML, -is YAML
                            Input YAML file containing the schema for ISA.
      --schema_platform YAML, -ps YAML
                            Input YAML file containing the schema for Platform.
      --verbose             debug | info | warning | error
      -h, --help            show this help message and exit

Example:

.. code-block:: bash


    python3 -m rips.main \
    -ii Examples/template_isa.yaml \
    -pi Examples/template_platform.yaml \
    -is rips/schema-isa.yaml \
    -ps rips/schema-platform.yaml \
    -ei Examples/template_env.yaml \
    --verbose debug


