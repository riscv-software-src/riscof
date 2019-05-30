import logging
import common.utils as utils
from framework.test_list import *
import filecmp

logger = logging.getLogger(__name__)

def compare_signature(file1,file2):
    if( filecmp.cmp(file1,file2) ):
        status='Passed'
    else:
        status='Failed'
    return status

def collect_unprivilege(isa):
    global user_target
    dut_test_pool = []
    for test in unprivilege_test_pool:
        if(len(test)<2):
            logger.error('Test list should be atleast 2 entries: Test name and\
 march')
            sys.exit(0)
        if(len(test)==2):
            dut_test_pool.append(test)
        else:
            criteria = test[2:]
            select = True
            for c in criteria:
                if not eval(c.lower()):
                    select=False
            if select:
                dut_test_pool.append(test)
            #     if 'in' in c:
            #         x = c.split();
            #         if (len(x)!=3):
            #             logger.error('Wrong Criteria Syntax for test: '+\
            #                         str(test[0]))
            #             sys.exit(0)

            #         if x[0].isdigit():
            #             if int(x[0]) not in foo[x[2]]:
            #                 select=False
            #         elif x[0] not in foo[x[2]]:
            #             select=False
            # if select:
            #     dut_test_pool.append([test[0],test[1]])
    return dut_test_pool

def execute(dut,base,ispec,pspec):
    test_pool = collect_unprivilege(ispec['ISA'].lower())
    log = []
    for entry in test_pool:
        logger.info("Test file:"+entry[0])
        logger.info("Initiating Compilation.")
        dut.compile(entry[0]," -DTEST_PART_1=True",ispec['ISA'].lower())
        logger.info("Running DUT simulation.")
        res = dut.simulate(entry[0])
        logger.info("Running Base Model simulation")
        ref = base.simulate(entry[0])
        logger.info("Initiating check.")
        log.append([entry[0],compare_signature(res,ref)])
    
    logger.info('Following '+str(len(test_pool))+' Unprivileged \
tests have been run :\n')
    logger.info('{0:<25s} : {1}\n'.format('TEST NAME','STATUS'))
    # print(log)
    for x in range(0,len(test_pool)):
        if(log[x][1]=='Passed'):
            logger.info('{0:<25s}: {1}'.format(\
                log[x][0], log[x][1]))
        else:
            logger.error('{0:<25s}: {1}'.format(\
                log[x][0], log[x][1]))

