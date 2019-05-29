import os
import re
import shutil
import subprocess
import shlex
import logging
import common.utils as utils
from plugin.pluginTemplate import pluginTemplate
import random
import string

logger= logging.getLogger(__name__)

class model_from_yaml(pluginTemplate):
    def __init__(self,*args, **kwargs):
        self.name = kwargs.get('name',''.join(random.choices(string.ascii_uppercase + string.digits, k=10)))
    def initialise_from_file(self,file):
        foo = utils.loadyaml(file)
        # logger.info("Initialising parameters of model.")
        compile_flags=' -static -mcmodel=medany -fvisibility=hidden -nostdlib \
        -nostartfiles '
        self.simulator = foo['USER_EXECUTABLE']
        self.signature = foo['USER_SIGN']
        self.pref = foo['RISCV_PREFIX']
        self.post = foo['USER_POST_SIM']['command']
        self.is_post_shell = foo['USER_POST_SIM']['is_shell']
        self.pre = foo['USER_PRE_SIM']['command']
        self.is_pre_shell = foo['USER_PRE_SIM']['is_shell']
        self.root_dir=os.getcwd()+'/'
        self.gcc = foo['RISCV_PREFIX']+'gcc'
        self.ld  = foo['RISCV_PREFIX']+'ld'
        self.linker = self.root_dir+foo['USER_LINKER']
        self.env_dir = self.root_dir+foo['USER_ENV_DIR']+'/'
        self.march = re.sub('[nsu]','',foo['ISA'].lower())
        self.user_abi  = foo['USER_ABI'].lower()
        self.user_target=foo['USER_TARGET']
        self.work_dir=self.root_dir+'work/'
        self.user_sign = foo['USER_SIGN']
        self.objdump = foo['RISCV_PREFIX']+'objdump -D '
        self.buildsc = foo['BUILD']
        if not os.path.exists(self.work_dir):
            logger.debug('Creating new work directory: '+self.work_dir)
            os.mkdir(self.work_dir)
        else:
            logger.debug('Removing old work directory: '+self.work_dir)
            shutil.rmtree(self.work_dir)
            logger.debug('Creating new work directory: '+self.work_dir)
            os.mkdir(self.work_dir)
    
        self.compile_cmd = self.gcc+ ' -march={0} -mabi={1} '+compile_flags+'-I' + self.env_dir +\
                ' -T'+self.linker
        self.objdump = foo['RISCV_PREFIX']+'objdump -D '
    
    # def build(self):
    #     logger.debug(self.buildsc)
    
    def presim(self,file):
        # logger.debug("Changing directory to "+self.work_dir+str(file)+'/')
        # os.chdir(self.work_dir+str(file)+'/')
        pre_sim = self.pre + file
        logger.debug(pre_sim)
    
    def postsim(self,file):
        logger.debug("Changing directory to "+self.work_dir+str(file)+'/')
        os.chdir(self.work_dir+str(file)+'/')
        # logger.info("Running post-sim for "+file)
        utils.execute_sim_command(self.env_dir,self.post,self.is_post_shell)

    def simulate(self,file):
        test_dir = self.work_dir+str(file)+'/'
        os.chdir(test_dir)
        elf = test_dir+str(file)+'.elf'
        utils.execute_command(self.simulator+elf)

    def compile(self,file,macros):
        # logger.info("Running "+file+" test")
        test = self.root_dir+'suite/'+str(file)+'.S'
        test_dir = self.work_dir+str(file)+'/'
        shutil.rmtree(test_dir, ignore_errors=True)
        os.mkdir(test_dir)
        os.chdir(test_dir)
        elf = test_dir+str(file)+'.elf'
        # print("kk"+elf)
        cmd=self.compile_cmd.format("rv32i",self.user_abi)+' '+test+' -o '+elf
        # print(cmd)
        execute = cmd+macros
        # logger.debug(execute)
        # x=subprocess.Popen(shlex.split(execute))
        utils.execute_command(execute)
        cmd=self.objdump.format(test,self.user_abi)+' '+elf
        utils.execute_command_log(cmd, '{}.disass'.format(str(file)))
#        os.chdir(work_dir)
        # logger.info("Initiating Simulation")
        