import logging
import filecmp
import re
import sys
import os

import riscof.utils as utils
import riscof.constants as constants

logger = logging.getLogger(__name__)


def compare_signature(file1, file2):
    '''Function to check whether two files are equivalent.
    '''
    if (filecmp.cmp(file1, file2)):
        status = 'Passed'
    else:
        status = 'Failed'
    return status


def eval_cond(condition, spec):
    '''Function to evaluate the "check" statement in the database entry.
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
    '''Function to evaluate the "def" statements in the database entry and return the macro string.'''
    args = (macro.replace("def ", " -D")).split("=")
    if (">" not in args[1]):
        return [True, str(args[0]) + "=" + str(args[1])]


def generate_test_pool(ispec, pspec):
    '''Funtion to select the tests which are applicable for the DUT and generate the macros
    necessary for each test.'''
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
            test_pool.append(
                [file, db[file]['commit_id'], macros, db[file]['isa']])
    return test_pool


def run_tests(dut, base, ispec, pspec):
    '''Function to run the tests for the DUT.'''
    logger.info("Selecting Tests.")
    test_pool = generate_test_pool(ispec, pspec)
    log = []
    isa = ispec['ISA']
    for entry in test_pool:
        logger.info("Test file:" + entry[0])
        logger.info("Initiating Compilation.")
        dut.compile(entry[0], entry[2], entry[3])
        logger.info("Running DUT simulation.")
        res = dut.simulate(entry[0], isa)
        logger.info("Running Base Model simulation.")
        ref = base.simulate(entry[0], isa)
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
