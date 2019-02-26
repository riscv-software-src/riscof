from cerberus import Validator
import oyaml as yaml
import sys
import os
import re
import logging
import subprocess
import shutil
from framework.test_list import *
import random
import common.utils
import shlex

global compile_cmd
global objdump
global root_dir
global work_dir
global user_sign
global user_target
global env_dir

logger= logging.getLogger(__name__)

def load_yaml(inp_file):
    global compile_cmd
    global root_dir
    global objdump
    global work_dir
    global user_sign
    global user_target
    global env_dir
    compile_flags=' -static -mcmodel=medany -fvisibility=hidden -nostdlib \
 -nostartfiles '
  
    """
      Read the input foo (yaml file)
    """
    inputfile=open(inp_file,'r')
    # Load input YAML file
    foo=yaml.safe_load(inputfile)
    
    # exrtact user env and compile env
    root_dir=os.getcwd()+'/'
    gcc = foo['RISCV_PREFIX']+'gcc'
    ld  = foo['RISCV_PREFIX']+'ld'
    linker = root_dir+foo['USER_LINKER']
    env_dir = root_dir+foo['USER_ENV_DIR']+'/'
    march = re.sub('[nsu]','',foo['ISA'].lower())
    mabi  = foo['USER_ABI'].lower()
    user_target=foo['USER_TARGET']
    
    # Display Info about User Variables
    logger.info("--------------------------------------------------\n")
    logger.info("Target Information")
    logger.info("--------------------------------------------------\n")
    logger.info('Target-YAML-Input: '+str(inp_file))
    logger.info('Target-Name: '+foo['USER_TARGET'])
    logger.info('Target-Env-Dir: '+env_dir)
    logger.info('Target-GCC: '+gcc)
    logger.info('Target-Linker-script: '+linker)
    logger.info('Target-MARCH: '+march)
    logger.info('Target-ABI: '+mabi)

    work_dir=root_dir+'work/'
    user_sign = work_dir+foo['USER_SIGN']
    if not os.path.exists(work_dir):
        logger.debug('Creating new work directory: '+work_dir)
        os.mkdir(work_dir)
    else:
        logger.debug('Removing old work directory: '+work_dir)
        shutil.rmtree(work_dir)
        logger.debug('Creating new work directory: '+work_dir)
        os.mkdir(work_dir)
    
    compile_cmd = gcc + ' -march=' + march + ' -mabi=ilp32'  + compile_flags +\
    ' -I' + env_dir + ' -T'+linker
    objdump = foo['RISCV_PREFIX']+'objdump -D {0} > {1}'

    test_unprivilege(foo)
    test_warl(foo)

def compare_signature():
    global user_sign
    global user_target
    check_sign='diff -iqw '+user_sign+' '+work_dir+'reference'
    logger.debug(check_sign)
    x=subprocess.Popen(shlex.split(check_sign), stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE)
    out, err=x.communicate()
    status='Passed'
    if(err or out):
       # print('Signatures do not match')
       # print('Expected signature:')
       # with open(work_dir+'reference', 'r') as fin:
       #     print(fin.read())
       # print('Signature from '+user_target+':')
       # with open(user_sign, 'r') as fin:
       #     print(fin.read())
        status='Failed'
    return status

def collect_unprivilege(foo):
    global user_target
    dut_test_pool = []
    for test in unprivilege_test_pool:
        if(len(test)==1):
            dut_test_pool.append(test[0])
        else:
            criteria = test[1:]
            select = True
            for c in criteria:
                if 'in' in c:
                    x = c.split();
                    if (len(x)!=3):
                        logger.error('Wrong Criteria Syntax for test: '+\
                                    str(test[0]))
                        sys.exit(0)

                    if x[0].isdigit():
                        if int(x[0]) not in foo[x[2]]:
                            select=False
                    elif x[0] not in foo[x[2]]:
                        select=False
            if select:
                dut_test_pool.append(test[0])
    return dut_test_pool

def test_unprivilege(foo):
    global work_dir
    global root_dir
    global compile_cmd

    unprivilege_target_pool=collect_unprivilege(foo)
    unprivilege_target_status=[]
    simulator = foo['USER_EXECUTABLE']
    logger.info("--------------------------------------------------\n")
    logger.info("Running UnPrivileged Tests")
    logger.info("--------------------------------------------------\n")
    for asm in unprivilege_target_pool:
        logger.debug("\n")
        logger.debug('Running Unprivileged Test: '+asm)
        test = root_dir+'suite/'+asm+'.S'
        elf = work_dir+asm
        cmd=compile_cmd+' '+test+' -o '+elf

        execute = cmd+parse_test(test,foo, 0, 0, 0, 0)
        common.utils.execute_command(execute)
        os.chdir(work_dir)

        common.utils.execute_command(simulator+elf)
        post_sim_fix=env_dir+foo['USER_POST_SIM']
        common.utils.execute_command(post_sim_fix)

        os.chdir(root_dir)
        status=compare_signature()
        unprivilege_target_status.append(status)

    logger.info('Following '+str(len(unprivilege_target_pool))+' Unprivileged \
 tests have been run '+user_target+':\n')
    for x in range(0,len(unprivilege_target_pool)):
        if(unprivilege_target_status[x]=='Passed'):
            logger.info('{0:<25s}: {1}'.format(unprivilege_target_pool[x],
                                            unprivilege_target_status[x]))
        else:
            logger.error('{0:<25s}: {1}'.format(unprivilege_target_pool[x],
                                            unprivilege_target_status[x]))


def test_warl (foo):
    global compile_cmd
    global root_dir
    global objdump
    global user_sign
    # test of MPP_WARL
    simulator = foo['USER_EXECUTABLE']

    logger.info("\n--------------------------------------------------\n")
    logger.info("Running WARL Tests")
    logger.info("\n--------------------------------------------------\n")
    test_name=[]
    test_status=[]
    for asm in warl_test_list:
        test = root_dir+'suite/'+asm+'.S'
        elf = work_dir+asm
        legal, illegal=warl_resolver_exhaustive(foo['MSTATUS_MPP'], 2)
        cmd=compile_cmd+' '+test+' -o '+elf
        for i in range(len(legal)):
            for j in range(len(illegal)):
                logger.debug("\n")
                logger.debug('Running WARL Test: {0} with legal-values:{1} and \
#illegal-values:{2}'.format(asm,str(legal[i]),str(illegal[j])))
                execute=cmd + ' -DLEGAL=' + str(legal[i]) +\
                                  ' -DILLEGAL=' + str(illegal[j]) +\
                                  ' -DLEGAL_SATURATE_S=' +str(min(legal)) +\
                                  ' -DLEGAL_SATURATE_L=' +str(max(legal))
                execute = execute+parse_test(test,foo, legal[i], illegal[j], 
                            min(legal), max(legal))
                common.utils.execute_command(execute)
                os.chdir(work_dir)

                common.utils.execute_command(simulator+elf)

                post_sim_fix=env_dir+foo['USER_POST_SIM']
                common.utils.execute_command(post_sim_fix)

                os.chdir(root_dir)
                status=compare_signature()
                test_name.append(asm+' legal: '+str(legal[i]) + ' illegal: ' +\
                        str(illegal[j]))
                test_status.append(status)
                
    logger.info('Following '+str(len(test_name))+' WARL tests have been run ' +\
            user_target+':\n')
    for x in range(0,len(test_name)):
        if(test_status[x]=='Passed'):
            logger.info('{0:<25s}: {1}'.format(test_name[x],
                                            test_status[x]))
        else:
            logger.error('{0:<25s}: {1}'.format(test_name[x],
                                            test_status[x]))

    
def warl_resolver_exhaustive(node, field_size):
    legal=[]
    illegal=[]
    max_value = 2**field_size-1
    if 'distinct' in node:
        legal=node['distinct']['values']
        for i in range(max_value+1):
            if i not in legal:
                illegal.append(i)
    return legal, illegal

def warl_resolver_random(node, field_size):
    legal=[]
    illegal=[]
    max_value = 2**field_size-1
    if 'distinct' in node:
        legal=node['distinct']['values']
    while len(illegal)==0:
        rand_illegal = random.randint(0,max_value-1)
        if rand_illegal not in legal:
            illegal.append(rand_illegal)
    return legal, illegal

def parse_test(file_name, foo, legal, illegal, legal_saturate_s,
        legal_saturate_l):
    global work_dir
    macro=''
    fout = open(work_dir+'reference','w')
    test_part_flag = False
    test_val = True
    fin = open(file_name,'r') 
    
    test_part_flag = False
    signature_entries= 0
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

        if "RVTEST_PART_START" in line:
            if test_part_flag == True:
                logger.error("{}:{}: Did not finish ({}) start".format(file_name, line_number, test_part_number))
                sys.exit(0)
            args = [temp.strip() for temp in (line.strip()).replace('RVTEST_PART_START','')[1:-1].split(',')]
            
            if int(test_part_number) >= int(args[0]):
                logger.error("{}:{}: Incorrect Naming of Test Case after ({})".format(file_name, line_number, test_part_number))
                sys.exit(0)
            
            test_part_number = args[0]                
            test_part_flag = True
        
        
        elif "RVTEST_PART_RUN" in line:
            if bool(re.match(r"RVTEST_PART_RUN\((.*)[0-9](.*):(.*)\s*\)", line)) == False:
                logger.error("{}:{}: Incorrect Syntax in {}".format(file_name, line_number, test_part_number))
                sys.exit(0)
            
            args = re.search(r'RVTEST_PART_RUN\(\s*(.*)\s*,\s*\"(.*):(.*)\"\)', line)

            if args.group(1) != test_part_number:
               logger.error("{}:{}: Wrong Test Case Numbering in ({})".format(file_name, line_number, test_part_number))
               sys.exit(0)
            
            key=args.group(2).split('>')
            compare=foo[key[0]]
            for k in range(1,len(key)):
                compare=compare[key[k]]
            if(args.group(3) not in compare):
                test_val=False
                test_part_flag=False
        
        elif "RVTEST_IO_ASSERT_GPR_EQ" in line and test_part_flag == True:
            args = [temp.strip() for temp in (line.strip()).replace('RVTEST_IO_ASSERT_GPR_EQ','')[1:-1].split(',')]
            if args[2][:2] == '0x':
                temp = hex(int(args[2],16))[2:]
                fout.write(temp.zfill(8) + "\n")
            elif args[2] == 'LEGAL':
                fout.write(hex(legal)[2:].zfill(8) + "\n")
            elif args[2] == 'LEGAL_SATURATE_S':
                fout.write(hex(legal_saturate_s)[2:].zfill(8) + "\n")
            elif args[2] == 'LEGAL_SATURATE_L':
                fout.write(hex(legal_saturate_l)[2:].zfill(8) + "\n")
            elif args[2] == 'ILLEGAL':
                fout.write(hex(illegal)[2:].zfill(8) + "\n")
            else:
                logger.error('Wrong syntax in Line: '+str(line_number)+'. ' +
                        args[2]+' Not a valid Argument')
                sys.exit(0)
            signature_entries=signature_entries+1
        
        elif "RVTEST_PART_END" in line and test_part_flag == True:
            args = [temp.strip() for temp in (line.strip()).replace('RVTEST_PART_END','')[1:-1].split(',')]
            if args[0] != test_part_number:
                logger.error("{}:{}: Wrong Test Case Numbering in ({})".format(file_name, line_number, test_part_number))
                sys.exit(0)
            
            if test_val:
                temp = hex(int(test_part_number))[2:]
                macro=macro+ ' -DTEST_PART_'+test_part_number+'=True'
                
            test_part_flag = False
            test_val = True
        
        elif "RV_COMPLIANCE_CODE_END" in line:

            fill_signatures = int(signature_entries) % 4
            if (fill_signatures != 0):
                fill_signatures = 4 - fill_signatures;
                for i in range(0, fill_signatures):
                    fout.write("0"*8 + "\n")
        
    if test_part_flag != False:
        logger.error("{}:{}: Did not finish ({}) start".format(file_name, line_number, test_part_number))
    return macro
    
