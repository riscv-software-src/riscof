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

  python3 -m rips.main --help

    usage: RIPS Checker [-h] --input_isa YAML --input_platform YAML --schema_isa
                        YAML --schema_platform YAML [--verbose]
    
    This Program checks an input YAML for compatibility with RIPS format
    
    optional arguments:
      --input_isa YAML, -ii YAML
                            Input YAML file containing ISA specs.
      --input_platform YAML, -pi YAML
                            Input YAML file containing platform specs.
      --schema_isa ISA, -is ISA
                            Input ISA Schema file
      --schema_platform PLATFORM, -ps PLATFORM
                            Input PLATFORM Schema file
      --verbose             debug | info | warning | error
      -h, --help            show this help message and exit

Example:

.. code-block:: bash

  
    python3 -m rips.main -ii Examples/template_isa.yaml \
      -pi Examples/template_platform.yaml \
      -is rips/schema-isa.yaml \
      -ps rips/schema-platform.yaml \
      --verbose debug



