from cerberus import Validator
import oyaml as yaml
import sys
import os
import re
import logging
import shlex
import subprocess
import shutil
from framework.test_list import *

logger= logging.getLogger(__name__)

def load_yaml(inp_file):

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
    env_dir = root_dir+foo['USER_ENV_DIR']
    march = re.sub('[nsu]','',foo['ISA'].lower())
    mabi  = foo['USER_ABI'].lower()
    
    # Display Info about User Variables
    logger.info('Target Name: '+foo['USER_TARGET'])
    logger.info('Target Env Dir: '+env_dir)
    logger.info('Target GCC: '+gcc)
    logger.info('Target Linker Script: '+linker)
    logger.info('Target MARCH: '+march)
    logger.info('Target ABI: '+mabi)

    work_dir=root_dir+'work/'
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

    test_priv(foo, compile_cmd, root_dir)

def test_priv (foo, compile_cmd, root_dir):

    # test of MPP_WARL
    simulator = foo['USER_EXECUTABLE']
    test = root_dir+test_list[0]
    work_dir=root_dir+'work/'
    legal, illegal, legal_next=warl_resolver(foo['MSTATUS_MPP'], 2)
    compile_cmd=compile_cmd+' '+test+' -o '+work_dir+'myelf'
    for i in range(len(legal)):
        for j in range(len(illegal)):
            execute=compile_cmd + ' -DMPP_LLEGAL=' + str(legal[i]) +\
                                      ' -DMPP_ILLEGAL=' + str(illegal[j]) +\
                                      ' -DMPP_LEGAL_NEXT=' + str(legal_next[i*j])
            logger.debug(execute)
            x=subprocess.Popen(shlex.split(execute), stdout=subprocess.PIPE,
                                                        stderr=subprocess.PIPE)
            out, err=x.communicate()
            if(err):
                logger.error(err.rstrip().decode('ascii'))
                sys.exit(0)
            if(out):
                logger.debug(out.rstrip().decode('ascii'))
            os.chdir(work_dir)

            sim = simulator+'myelf'
            logger.debug(sim)
            x=subprocess.Popen(shlex.split(sim), stdout=subprocess.PIPE,
                                                        stderr=subprocess.PIPE)
            out, err=x.communicate()
            if(err):
                logger.error(err.rstrip().decode('ascii'))
                sys.exit(0)
            if(out):
                logger.debug(out.rstrip().decode('ascii'))
            os.chdir(root_dir)
            #sys.exit(0)

    
def warl_resolver(node, field_size):
    legal=[]
    illegal=[]
    legal_next=[]
    max_value = 2**field_size-1
    if 'distinct' in node:
        legal=node['distinct']['values']
        for i in range(max_value+1):
            if i not in legal:
                illegal.append(i)
        if node['distinct']['modes']=='unchanged':
            for i in range(len(legal)): 
                for j in range(len(illegal)):
                    legal_next.append(legal[i])
        elif node['distinct']['modes']=='next_l':
            for i in range(len(legal)): 
                for j in range(len(illegal)):
                    temp = [k for k in legal if k > illegal[j]]
                    legal_next.append(min(temp))
        elif node['distinct']['modes']=='next_s':
            for i in range(len(legal)): 
                for j in range(len(illegal)):
                    temp = [k for k in legal if k < illegal[j]]
                    legal_next.append(max(temp))
    return legal, illegal, legal_next

#
#    elif 'bitmask' in node:
#        print(node['bitmask'])
#    elif 'range' in node:
#        print(node['range'])
#    else:
#        logger.error('Unsupported WARL mode encountered: '+node)
#        sys.exit(0)

    
