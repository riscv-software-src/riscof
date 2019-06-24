import logging
import importlib
import shutil
import os

from .test import run_tests
import riscof.utils as utils
import riscof.constants as constants

logger = logging.getLogger(__name__)


def run(dut_model, dut_env_file, base_model, base_env_file, dut_isa_spec,
        dut_platform_spec):
    work_dir = constants.work_dir
    #Creating work directory
    if not os.path.exists(work_dir):
        logger.debug('Creating new work directory: ' + work_dir)
        os.mkdir(work_dir)
    else:
        logger.debug('Removing old work directory: ' + work_dir)
        shutil.rmtree(work_dir)
        logger.debug('Creating new work directory: ' + work_dir)
        os.mkdir(work_dir)

    logger.info("Preparing Models")
    # Gathering Models
    logger.debug("Importing " + dut_model + " plugin")
    dut_plugin = importlib.import_module("riscof.plugins." + dut_model)
    dut_class = getattr(dut_plugin, dut_model)
    dut = dut_class(name="DUT")
    logger.debug("Importing " + base_model + " plugin")
    base_plugin = importlib.import_module("riscof.plugins." + base_model)
    base_class = getattr(base_plugin, base_model)
    base = base_class(name="Reference")

    # Setting up models
    if dut_env_file is not None:
        logger.debug("Initialising DUT model with " + dut_env_file)
        dut.initialise(file=dut_env_file,
                       work_dir=work_dir,
                       suite=constants.suite)
    else:
        dut.initialise(work_dir=work_dir, suite=constants.suite)
    if base_env_file is not None:
        logger.debug("Initialising BASE model with " + base_env_file)
        base.initialise(file=base_env_file,
                        work_dir=work_dir,
                        suite=constants.suite)
    else:
        base.initialise(work_dir=work_dir, suite=constants.suite)
    #Loading Specs
    ispec = utils.load_yaml(dut_isa_spec)
    pspec = utils.load_yaml(dut_platform_spec)

    logger.debug("Running Build for DUT")
    dut.build(dut_isa_spec, dut_platform_spec, ispec['ISA'].lower())
    logger.debug("Running Build for Base")
    base.build(dut_isa_spec, dut_platform_spec, ispec['ISA'].lower())

    run_tests(dut, base, ispec, pspec)
    # framework.test_execute.load_yaml(input)


if __name__ == '__main__':
    run()
