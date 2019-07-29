import logging
import importlib
import shutil
import os

from riscof.framework.test import run_tests
import riscof.utils as utils
import riscof.constants as constants

logger = logging.getLogger(__name__)


def run(dut, base, dut_isa_spec, dut_platform_spec):
    '''
        Entry point for the framework module. This function initializes and sets up the required 
        variables for the tests to run.

        :param dut: The class instance for the DUT model.

        :param base: The class instance for the BASE model.

        :param dut_isa_spec: The absolute path to the checked yaml containing 
            the DUT isa specification.
        
        :param dut_platform_spec: The absolute path to the checked yaml containing 
            the DUT platform specification.
        
        :type dut_platform_spec: str

        :type dut_isa_spec: str

        :return: A list of dictionary objects containing the necessary information
            required to generate the report given from the :py:mod:`riscof.framework.test` module.

    '''
    work_dir = constants.work_dir

    # Setting up models
    dut.initialise(constants.suite, work_dir, constants.env)
    base.initialise(constants.suite, work_dir, constants.env)
    #Loading Specs
    ispec = utils.load_yaml(dut_isa_spec)
    pspec = utils.load_yaml(dut_platform_spec)

    logger.debug("Running Build for DUT")
    dut.build(dut_isa_spec, dut_platform_spec)
    logger.debug("Running Build for Base")
    base.build(dut_isa_spec, dut_platform_spec)

    results = run_tests(dut, base, ispec, pspec)

    return results


if __name__ == '__main__':
    run()
