import logging
import importlib
from datetime import datetime
import os
import pytz
from shutil import copyfile

from jinja2 import Template

import riscof
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

    report_objects = {}
    report_objects['date'] = (datetime.now(
        pytz.timezone('GMT'))).strftime("%Y-%m-%d %H:%M GMT")
    report_objects['version'] = riscof.__version__
    report_objects['dut'] = (dut.__model__).replace("_", " ")
    report_objects['reference'] = (base.__model__).replace("_", " ")

    isa_specs = utils.load_yaml(isa_file)

    with open(isa_file, "r") as isafile:
        ispecs = isafile.read()

    with open(platform_file, "r") as platfile:
        platform_specs = platfile.read()

    report_objects['isa'] = isa_specs['ISA']
    report_objects['usv'] = isa_specs['User_Spec_Version']
    report_objects['psv'] = isa_specs['Privilege_Spec_Version']
    report_objects['isa_yaml'] = isa_file
    report_objects['platform_yaml'] = platform_file
    report_objects['isa_specs'] = ispecs
    report_objects['platform_specs'] = platform_specs

    report_objects['results'] = framework.run(dut, base, isa_file,
                                              platform_file)

    report_objects['num_passed'] = 0
    report_objects['num_failed'] = 0

    for entry in report_objects['results']:
        if entry['res'] == "Passed":
            report_objects['num_passed'] += 1
        else:
            report_objects['num_failed'] += 1

    with open(constants.html_template, "r") as report_template:
        template = Template(report_template.read())

    output = template.render(report_objects)

    with open(os.path.join(constants.work_dir, "report.html"), "w") as report:
        report.write(output)

    copyfile(constants.css, os.path.join(constants.work_dir, "style.css"))

    try:
        import webbrowser
        webbrowser.open(os.path.join(constants.work_dir, "report.html"))
    except:
        return


if __name__ == "__main__":
    try:
        execute()
        exit(0)
    except ValidationError as msg:
        logger = logging.getLogger(__name__)
        logger.error(msg)
        exit(1)
