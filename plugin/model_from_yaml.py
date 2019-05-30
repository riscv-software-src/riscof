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
        self.name = kwargs.get('name',''.join(random.choices(string.ascii_uppercase + string.digits, k=10)))+":"
    def initialise_from_file(self,file,*args, **kwargs):
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
        self.suite=kwargs.get("suite")
        self.gcc = foo['RISCV_PREFIX']+'gcc'
        self.ld  = foo['RISCV_PREFIX']+'ld'
        self.root_dir = os.getcwd()+"/"
        self.linker = self.root_dir+foo['USER_LINKER']
        self.env_dir = self.root_dir+foo['USER_ENV_DIR']+'/'
        self.march = re.sub('[nsu]','',foo['ISA'].lower())
        self.user_abi  = foo['USER_ABI'].lower()
        self.user_target=foo['USER_TARGET']
        self.work_dir=kwargs.get("work_dir")
        self.user_sign = foo['USER_SIGN']
        self.objdump = foo['RISCV_PREFIX']+'objdump -D '
        self.buildsc = foo['BUILD']
        self.perform_pre = not self.pre is ''
        self.perform_post = not self.post is ''
    
        self.compile_cmd = self.gcc+ ' -march={0} -mabi={1} '+compile_flags+'-I' + self.env_dir +\
                ' -T'+self.linker
        self.objdump = foo['RISCV_PREFIX']+'objdump -D '
    
    def build(self):
        logger.debug(self.name+"Build")
    
    def simulate(self,file):
        test_dir = self.work_dir+str(file)+'/'
        logger.debug(self.name+"Changing directory to "+test_dir)
        os.chdir(test_dir)
        elf = test_dir+str(file)+'.elf'
        if self.perform_pre:
            presim = self.pre.replace("$elf",elf)
            logger.debug(self.name+"Pre Sim")
            utils.execute_sim_command(self.env_dir,presim,self.is_pre_shell)
        
        logger.debug(self.name+"Simulate")
        utils.execute_command(self.simulator.replace("$file",elf))

        if self.perform_post:
            logger.debug(self.name+"Post Sim")
            utils.execute_sim_command(self.env_dir,self.post,self.is_post_shell)

        sign_file = test_dir+self.name[:-1]+"_"+self.user_target+"_sign"
        cp = "cat "+test_dir+self.signature+" > "+ sign_file
        utils.execute_sim_command("",cp,True)
        return sign_file
    
    def compile(self,file,macros):
        # logger.info("Running "+file+" test")
        logger.debug(self.name+"Compile")
        test = self.suite+str(file)+'.S'
        test_dir = self.work_dir+str(file)+'/'
        shutil.rmtree(test_dir, ignore_errors=True)
        os.mkdir(test_dir)
        logger.debug(self.name+"Changing directory to "+test_dir)
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
        