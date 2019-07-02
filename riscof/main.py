import logging
import importlib

import riscof.rips.checker as rips
import riscof.framework.main as framework
import riscof.utils as utils
import riscof.constants as constants
from riscof.errors import ValidationError


def execute():
    '''
        Entry point for riscof. This function sets up the models and 
        calls the :py:mod:`rips` and :py:mod:`framework` modules with 
        appropriate arguments.
    '''
    # Set up the parser
    parser = utils.riscof_cmdline_args()
    args = parser.parse_args()

    # Set up the logger
    utils.setup_logging(args.verbose)
    logger = logging.getLogger()
    logger.handlers = []
    ch = logging.StreamHandler()
    ch.setFormatter(utils.ColoredFormatter())
    logger.addHandler(ch)
    fh = logging.FileHandler('run.log', 'w')
    logger.addHandler(fh)

    logger.info("Preparing Models")

    # Gathering Models
    dut_model = args.dut_model
    base_model = args.base_model
    logger.debug("Importing " + dut_model + " plugin")
    dut_plugin = importlib.import_module("riscof_" + dut_model)
    dut_class = getattr(dut_plugin, dut_model)
    dut = dut_class(name="DUT")
    logger.debug("Importing " + base_model + " plugin")
    base_plugin = importlib.import_module("riscof_" + base_model)
    base_class = getattr(base_plugin, base_model)
    base = base_class(name="Reference")

    #Run rips on inputs
    isa_file = dut.isa_spec
    platform_file = dut.platform_spec

    rips.check_specs(isa_file, constants.isa_schema, platform_file,
                     constants.platform_schema)

    file_name_split = isa_file.split('.')
    isa_file = file_name_split[0] + '_checked.' + file_name_split[1]

    file_name_split = platform_file.split('.')
    platform_file = file_name_split[0] + '_checked.' + file_name_split[1]

    framework.run(dut, base, isa_file, platform_file)


if __name__ == "__main__":
    execute()
