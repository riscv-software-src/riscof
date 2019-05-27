import os
import re
import shutil
import subprocess
import shlex
class fromSchema():
    def initialise(self,foo):
        compile_flags=' -static -mcmodel=medany -fvisibility=hidden -nostdlib \
        -nostartfiles '
        self.simulator = foo['USER_EXECUTABLE']
        self.signature = foo['USER_SIGN']
        self.pref = foo['RISCV_PREFIX']
        self.post = foo['USER_POST_SIM']
        self.pre = foo['USER_PRE_SIM']
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
        if not os.path.exists(self.work_dir):
            print('Creating new work directory: '+self.work_dir)
            os.mkdir(self.work_dir)
        else:
            print('Removing old work directory: '+self.work_dir)
            shutil.rmtree(self.work_dir)
            print('Creating new work directory: '+self.work_dir)
            os.mkdir(self.work_dir)
    
        self.compile_cmd = self.gcc+ ' -march={0} -mabi={1} '+compile_flags+'-I' + self.env_dir +\
                ' -T'+self.linker
        self.objdump = foo['RISCV_PREFIX']+'objdump -D '
    def presim(self,file):
        print(self.pre)
    def postsim(self,file):
        os.chdir(self.work_dir+str(file)+'/')
        post_sim_fix = self.env_dir+self.post
        subprocess.Popen(shlex.split(post_sim_fix))
    def execute(self,file,macros):
        test = self.root_dir+'suite/'+str(file)+'.S'
        test_dir = self.work_dir+str(file)+'/'
        shutil.rmtree(test_dir, ignore_errors=True)
        os.mkdir(test_dir)
        os.chdir(test_dir)
        elf = test_dir+str(file)+'.elf'
        print("kk"+elf)
        cmd=self.compile_cmd.format("rv32i",self.user_abi)+' '+test+' -o '+elf
        print(cmd)
        execute = cmd+macros
        print(execute)
        x=subprocess.Popen(shlex.split(execute))
        # common.utils.execute_command(execute)
        cmd=self.objdump.format(file,self.user_abi)+' '+elf
        cmd = cmd + ' > {}'.format('{}.disass'.format(str(file)))
        subprocess.Popen(shlex.split(cmd))
#        os.chdir(work_dir)
        print("simulation")
        subprocess.Popen(shlex.split(self.simulator+elf))