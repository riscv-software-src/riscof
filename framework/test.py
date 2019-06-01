import logging
import common.utils as utils
from framework.test_list import *
import filecmp
import re
import sys

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

def parsetest(file):
    macro=''
    test_part_flag = False
    test_val = True
    fin = open(file,'r') 
    
    test_part_flag = False
    test_part_start_flag = False
    # signature_entries= 0
    test_part_number = '0'
    line_number = 0
    test_part_skipped = 0

    for line in fin:
        line_number += 1
        line = line.strip()
        
        if line == "":
            continue
        
        if bool(re.match(r"^#", line)) == True:
            continue

        if test_part_start_flag:
            if "RVTEST_PART_RUN" in line:
                if bool(re.match(r"RVTEST_PART_RUN\((.*)[0-9](.*):(.*)\s*\)", line)) == False:
                    logger.error("{}:{}: Incorrect Syntax in {}".format(file_name, line_number, test_part_number))
                    sys.exit(0)

                args = re.search(r'RVTEST_PART_RUN\(\s*(.*)\s*,\s*\"(.*):(.*)\"\)', line)

                if args.group(1) != test_part_number:
                   logger.error("{}:{}: Wrong Test Case Numbering in ({})".format(file_name, line_number, test_part_number))
                   sys.exit(0)
               
        elif "RVTEST_PART_START" in line:
            if test_part_flag == True:
                logger.error("{}:{}: Did not finish ({}) start".format(file_name, line_number, test_part_number))
                sys.exit(0)
            args = [temp.strip() for temp in (line.strip()).replace('RVTEST_PART_START','')[1:-1].split(',')]
            
            if int(test_part_number) >= int(args[0]):
                logger.error("{}:{}: Incorrect Naming of Test Case after ({})".format(file_name, line_number, test_part_number))
                sys.exit(0)
            
            test_part_number = args[0]                
            test_part_start_flag = True
        
        
    if test_part_flag != False:
        logger.error("{}:{}: Did not finish ({}) start".format(file_name, line_number, test_part_number))
def execute(dut,base,ispec,pspec):
    test_pool = collect_unprivilege(ispec['ISA'].lower())
    log = []
    for entry in test_pool:
        isa = ispec['ISA'].lower()
        logger.info("Test file:"+entry[0])
        logger.info("Initiating Compilation.")
        dut.compile(entry[0]," -DTEST_PART_1=True",isa)
        logger.info("Running DUT simulation.")
        res = dut.simulate(entry[0],isa)
        logger.info("Running Base Model simulation.")
        ref = base.simulate(entry[0],isa)
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

