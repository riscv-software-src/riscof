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
    logger.info('Loading input file: '+str(inp_file))
    foo=yaml.safe_load(inputfile)
    logger.debug('Input YAML:\n\t\t '+str(foo))
    logger.debug('Suite List '+str(test_list))
    
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
    logger.info('Target Name: '+foo['USER_TARGET'])
    logger.info('Target Env Dir: '+env_dir)
    logger.info('Target GCC: '+gcc)
    logger.info('Target Linker Script: '+linker)
    logger.info('Target MARCH: '+march)
    logger.info('Target ABI: '+mabi)

    work_dir=root_dir+'work/'
    user_sign = work_dir+foo['USER_SIGN']
    if not os.path.exists(work_dir):
        logger.info('Creating new work directory: '+work_dir)
        os.mkdir(work_dir)
    else:
        logger.info('Removing old work directory: '+work_dir)
        shutil.rmtree(work_dir)
        logger.info('Creating new work directory: '+work_dir)
        os.mkdir(work_dir)
    
    compile_cmd = gcc + ' -march=' + march + ' -mabi=' + mabi + compile_flags +\
    ' -I' + env_dir + ' -T'+linker
    objdump = foo['RISCV_PREFIX']+'objdump -D {0} > {1}'

    test_priv(foo)

def compare_signature():
    global user_sign
    global user_target
    check_sign='diff -iqw '+user_sign+' '+work_dir+'reference'
    logger.debug(check_sign)
    x=subprocess.Popen(shlex.split(check_sign), stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE)
    out, err=x.communicate()
    if(err or out):
        print('Signatures do not match')
        print('Expected signature:')
        with open(work_dir+'reference', 'r') as fin:
            print(fin.read())
        print('Signature from '+user_target+':')
        with open(user_sign, 'r') as fin:
            print(fin.read())
        sys.exit(0)

def test_priv (foo):
    global compile_cmd
    global root_dir
    global objdump
    global user_sign
    # test of MPP_WARL
    simulator = foo['USER_EXECUTABLE']
    for asm in test_list:
        test = root_dir+'suite/'+asm+'.S'
        elf = work_dir+asm
        legal, illegal=warl_resolver_exhaustive(foo['MSTATUS_MPP'], 2)
        compile_cmd=compile_cmd+' '+test+' -o '+elf
        for i in range(len(legal)):
            for j in range(len(illegal)):
                execute=compile_cmd + ' -DMPP_LEGAL=' + str(legal[i]) +\
                                  ' -DMPP_ILLEGAL=' + str(illegal[j]) +\
                                  ' -DMPP_LEGAL_SATURATE_S=' +str(min(legal)) +\
                                  ' -DMPP_LEGAL_SATURATE_L=' +str(max(legal))
                execute = parse_test(test,foo,execute)
                common.utils.execute_command(execute)
                os.chdir(work_dir)

                common.utils.execute_command(simulator+elf)

                post_sim_fix=env_dir+foo['USER_POST_SIM']
                common.utils.execute_command(post_sim_fix)

                os.chdir(root_dir)
                compare_signature()
                logger.info('Test Passed')

    
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

def parse_test(file_name, foo, compile_cmd):
    global work_dir
    fout = open(work_dir+'reference','w')
    test_part_flag = False
    test_val = False
    fin = open(file_name,'r') 
    
    test_part_flag = False
    test_case_number = '0'
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
                print("{}:{}: Did not finish ({}) start".format(file_in, line_number, test_case_number))
                exit()
            args = [temp.strip() for temp in (line.strip()).replace('RVTEST_PART_START','')[1:-1].split(',')]
            
            if int(test_case_number) >= int(args[0]):
                print("{}:{}: Incorrect Nameing of Test Case after ({})".format(file_in, line_number, test_case_number))
                exit()
            
            test_case_number = args[0]                
            test_part_flag = True
        
        
        elif "RVTEST_PART_RUN" in line:
            if bool(re.match(r"RVTEST_PART_RUN\((.*)[0-9](.*):(.*)\s*\)", line)) == False:
                print("{}:{}: Incorrect Syntax in {}".format(file_in, line_number, test_case_number))
                exit()
            
            args = re.search(r'RVTEST_PART_RUN\(\s*(.*)\s*,\s*\"(.*):(.*)\"\)', line)

            if args.group(1) != test_case_number:
               print("{}:{}: Wrong Test Case Numbering in ({})".format(file_in, line_number, test_case_number))
               exit()
            
            key=args.group(2).split('>')
            compare=foo[key[0]]
            for k in range(1,len(key)):
                compare=compare[key[k]]
            if(compare == args.group(3)):
                test_val=True
                compile_cmd=compile_cmd+ ' -DTEST_PART_'+test_case_number+'=True'
            
            
#            skip_config = args.group(2)
#            skip_config = re.sub(r"\s*","", skip_config) 
#            if skip_config in config_list.keys():
#                config_value = args.group(3)
#                config_value = re.sub(r"\s*","", config_value) 
#                config_value = re.sub(r'\"',"", config_value)
#                value = str(config_list[skip_config])
#                if value == config_value:
#                    #print("{}: {} ??  {}".format(skip_config, config_value, value[0]))
#                    test_val = False
#            else:
#               print("{}:{}: Wrong Skip config in test case({})".format(file_in, line_number, test_case_number))
#               exit(1)
        
        elif "RVTEST_PART_END" in line and test_part_flag == True:
            args = [temp.strip() for temp in (line.strip()).replace('RVTEST_PART_END','')[1:-1].split(',')]
            if args[0] != test_case_number:
                print("{}:{}: Wrong Test Case Numbering in ({})".format(file_in, line_number, test_case_number))
                exit()
            
            if test_val == False:
                test_part_skipped = test_part_skipped + 1
            else:
                #print(test_case_number.zfill(8))
                fout.write(test_case_number.zfill(8) + "\n")
                
            test_part_flag = False
            test_val = False
        
        elif "RV_COMPLIANCE_CODE_END" in line:
            while(test_part_skipped > 0):
                fout.write("f"*8 + "\n")
                test_part_skipped = test_part_skipped - 1

            fill_signatures = int(test_case_number) % 4
            if (fill_signatures != 0):
                fill_signatures = 4 - fill_signatures;
                for i in range(0, fill_signatures):
                    fout.write("0"*8 + "\n")
        
    if test_part_flag != False:
        print("{}:{}: Did not finish ({}) start".format(file_in, line_number, test_case_number))
    return compile_cmd
    
