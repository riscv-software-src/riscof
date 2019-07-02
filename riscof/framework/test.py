import logging
import filecmp
import re
import sys
import os

import riscof.utils as utils
import riscof.constants as constants

logger = logging.getLogger(__name__)


def compare_signature(file1, file2):
    '''
        Function to check whether two signature files are equivalent. This funcion uses the
        :py:mod:`filecmp` to perform the comparision.

        :param file1: The path to the first signature.

        :param file2: The path to the second signature.

        :type file1: str

        :type file2: str

        :return: A string indicating whether the test "Passed" (if files are the same)
            or "Failed" (if the files are different).

    '''
    if (filecmp.cmp(file1, file2)):
        status = 'Passed'
    else:
        status = 'Failed'
    return status


def eval_cond(condition, spec):
    '''
        Function to evaluate the "check" statements in the database entry and return the macro string.
        
        :param condition: The "check" statement in the test which needs to be evaluated.

        :param spec: The specifications of the DUT.

        :type condition: str

        :type spec: dict

        :return: A boolean value specifying whether the condition is satisfied by
            the given specifications or not.
    '''
    condition = (condition.replace("check", '')).strip()
    if ':=' in condition:
        temp = condition.split(":=")
        keys = temp[0].split(">")
        for key in keys:
            try:
                spec = spec[key]
            except KeyError:
                return False
        if "regex(" in temp[1]:
            exp = temp[1].replace("regex(", "r\"")[:-1] + ("\"")
            x = re.match(eval(exp), spec)
            if x is None:
                return False
            else:
                return True


def eval_macro(macro, spec):
    '''
        Function to evaluate the "def" statements in the database entry and return the macro string.
        
        :param macro: The "def" statement in the test which needs to be evaluated.

        :param spec: The specifications of the DUT.

        :type macro: str

        :type spec: dict

        :return: A 2 entry tuple. The first one being a boolean value indicating
            whether the macro was successfully defined and the second being the 
            macro statement to be used while compilatio( in gcc format).

    '''
    args = (macro.replace("def ", " -D")).split("=")
    if (">" not in args[1]):
        return (True, str(args[0]) + "=" + str(args[1]))


def generate_test_pool(ispec, pspec):
    '''
        Funtion to select the tests which are applicable for the DUT and generate the macros
        necessary for each test.
    
        :param ispec: The isa specification for the DUT.

        :param pspec: The platform specification for the DUT.

        :type ispec: dict

        :type pspec: dict

        :return: A list of 3 entry tuples. Each entry in a list corresponds to a
            test which should be executed. In each tuple, the first entry is the 
            path to the test relative to the riscof root, the second entry is the 
            list of macros for the test and the third entry is the 
            isa(adhering to RISCV specifications) required for the test.

    '''
    spec = {**ispec, **pspec}
    test_pool = []
    db = utils.load_yaml(constants.framework_db)
    for file in db:
        macros = ''
        for part in db[file]['parts']:
            include = True
            part_dict = db[file]['parts'][part]
            logger.debug("Checking conditions for {}-{}".format(file, part))
            for condition in part_dict['check']:
                include = include and eval_cond(condition, spec)
            for macro in part_dict['define']:
                temp = eval_macro(macro, spec)
                if (temp[0] and include):
                    macros = macros + temp[1]
        if not macros == '':
            if '32' in db[file]['isa']:
                xlen = '32'
            elif '64' in db[file]['isa']:
                xlen = '64'
            elif '128' in db[file]['isa']:
                xlen = '128'
            test_pool.append((file, db[file]['commit_id'],
                              macros + " -DXLEN=" + xlen, db[file]['isa']))
    return test_pool


def run_tests(dut, base, ispec, pspec):
    '''
        Function to run the tests for the DUT.

        :param dut: The class instance for the DUT model.

        :param base: The class instance for the BASE model.

        :param ispec: The isa specifications of the DUT.

        :param pspec: The platform specifications of the DUT.

        :type ispec: dict

        :type pspec: dict
    '''
    logger.info("Selecting Tests.")
    test_pool = generate_test_pool(ispec, pspec)
    log = []
    for entry in test_pool:
        logger.info("Test file:" + entry[0])
        logger.info("Initiating Compilation.")
        dut.compile(entry[0], entry[2], entry[3])
        logger.info("Running DUT simulation.")
        res = dut.simulate(entry[0])
        logger.info("Running Base Model simulation.")
        ref = base.simulate(entry[0])
        logger.info("Initiating check.")
        log.append([entry[0], entry[1], compare_signature(res, ref)])

    logger.info('Following ' + str(len(test_pool)) + ' tests have been run :\n')
    logger.info('{0:<50s} : {1:<40s} : {2}'.format('TEST NAME', 'COMMIT ID',
                                                   'STATUS'))
    # print(log)
    for x in range(0, len(test_pool)):
        if (log[x][2] == 'Passed'):
            logger.info('{0:<50s} : {1:<40s} : {2}'.format(\
                log[x][0], log[x][1], log[x][2]))
        else:
            logger.error('{0:<50s} : {1:<40s} : {2}'.format(\
                log[x][0], log[x][1], log[x][2]))
