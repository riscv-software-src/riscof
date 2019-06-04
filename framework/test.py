import logging
import common.utils as utils
import filecmp
import re
import sys
import os
import oyaml as yaml

logger = logging.getLogger(__name__)

def compare_signature(file1,file2):
    if( filecmp.cmp(file1,file2) ):
        status='Passed'
    else:
        status='Failed'
    return status

def eval_cond(condition,spec):
    condition = (condition.replace("check",'')).strip()
    if ':=' in condition:
        temp = condition.split(":=")
        keys = temp[0].split(">")
        for key in keys:
            try:
                spec = spec[key]
            except KeyError:
                return False
        if "regex(" in temp[1]:
            exp = temp[1].replace("regex(","r\"")[:-1]+("\"")
            return re.match(eval(exp),spec)

def eval_macro(macro,spec):
    args = (macro.replace("def "," -D")).split("=")
    if(">" not in args[1]):
        return [True,str(args[0])+"="+str(args[1])]

def eval_tests(ispec,pspec):
    spec = {**ispec,**pspec}
    test_pool = []
    with open(os.getcwd()+"/framework/database.yaml","r") as dbfile:
        db = yaml.safe_load(dbfile)
        for file in db:
            macros = ''
            for part in db[file]['parts']:
                include = True
                part_dict = db[file]['parts'][part]
                logger.debug("Checking conditions for {}-{}".format(file,part))
                for condition in part_dict['check']:
                    include = include and eval_cond(condition,spec)
                for macro in part_dict['define']:
                    temp = eval_macro(macro,spec)
                    if(temp[0] and include):
                        macros = macros + temp[1]
            if not macros == '' :
                test_pool.append([file,db[file]['commit_id'],macros])
    return test_pool

def execute(dut,base,ispec,pspec):
    logger.info("Selecting Tests.")
    test_pool = eval_tests(ispec,pspec)
    log = []
    for entry in test_pool:
        isa = ispec['ISA'].lower()
        logger.info("Test file:"+entry[0])
        logger.info("Initiating Compilation.")
        dut.compile(entry[0],entry[2],isa)
        logger.info("Running DUT simulation.")
        res = dut.simulate(entry[0],isa)
        logger.info("Running Base Model simulation.")
        ref = base.simulate(entry[0],isa)
        logger.info("Initiating check.")
        log.append([entry[0],entry[1],compare_signature(res,ref)])
    
    logger.info('Following '+str(len(test_pool))+' Unprivileged \
tests have been run :\n')
    logger.info('{0:<50s} : {1:<40s} : {2}'.format('TEST NAME','COMMIT ID','STATUS'))
    # print(log)
    for x in range(0,len(test_pool)):
        if(log[x][2]=='Passed'):
            logger.info('{0:<50s} : {1:<40s} : {2}'.format(\
                log[x][0], log[x][1], log[x][2]))
        else:
            logger.error('{0:<50s} : {1:<40s} : {2}'.format(\
                log[x][0], log[x][1], log[x][2]))

