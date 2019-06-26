import os
import re
import shutil
import subprocess
import shlex
import logging
import random
import string
from string import Template

import riscof.utils as utils
from riscof.plugins.pluginTemplate import pluginTemplate

logger = logging.getLogger(__name__)

map = {
    'rv32i': 'rv32i',
    'rv32im': 'rv32im',
    'rv32ic': 'rv32ic',
    'rv32ia': 'rv32ia'
}


class model_from_yaml(pluginTemplate):

    def __init__(self, *args, **kwargs):
        return super().__init__(*args, **kwargs)

    def initialise(self, *args, **kwargs):
        foo = utils.load_yaml(kwargs.get("file"))
        compile_flags = ' -static -mcmodel=medany -fvisibility=hidden -nostdlib \
        -nostartfiles '

        self.simulator = foo['USER_EXECUTABLE']
        self.signature = foo['USER_SIGN']
        self.pref = foo['RISCV_PREFIX']
        self.post = foo['USER_POST_SIM']['command']
        self.is_post_shell = foo['USER_POST_SIM']['is_shell']
        self.pre = foo['USER_PRE_SIM']['command']
        self.is_pre_shell = foo['USER_PRE_SIM']['is_shell']
        self.suite = kwargs.get("suite")
        self.gcc = foo['RISCV_PREFIX'] + 'gcc'
        self.ld = foo['RISCV_PREFIX'] + 'ld'
        self.root_dir = os.getcwd() + "/"
        self.linker = self.root_dir + foo['USER_LINKER']
        self.env_dir = self.root_dir + foo['USER_ENV_DIR'] + '/'
        self.user_abi = foo['USER_ABI'].lower()
        self.user_target = foo['USER_TARGET']
        self.work_dir = kwargs.get("work_dir")
        self.user_sign = foo['USER_SIGN']
        self.objdump = foo['RISCV_PREFIX'] + 'objdump -D '
        self.buildsc = foo['BUILD']
        self.perform_pre = not self.pre is ''
        self.perform_post = not self.post is ''
        self.perform_build = not self.buildsc is ''

        self.compile_cmd = self.gcc+ ' -march={0} -mabi={1} '+compile_flags+'-I' + self.env_dir +\
                ' -T'+self.linker
        self.objdump = foo['RISCV_PREFIX'] + 'objdump -D '

    def build(self, isa_yaml, platform_yaml, isa):
        if self.perform_build:
            logger.debug(self.name + "Build")
            d = dict(isaf=isa_yaml, platformf=platform_yaml, isa=isa)
            utils.execute_sim_command("",
                                      Template(self.buildsc).safe_substitute(d),
                                      True)

    def simulate(self, file, isa):
        test_dir = self.work_dir + str(file.replace(self.suite, '')[:-2]) + "/"
        elf = test_dir + str(file.split("/")[-1][:-2]) + '.elf'
        d = dict(elf=elf, testDir=test_dir, isa=isa)
        if self.perform_pre:
            logger.debug(self.name + "Pre Sim")
            command = Template(self.pre).safe_substitute(d)
            if self.is_pre_shell:
                utils.shellCommand(command).run(cwd=test_dir)
            else:
                utils.Command(command).run(cwd=test_dir)

        logger.debug(self.name + "Simulate")
        command = Template(self.simulator).safe_substitute(d)
        utils.Command(command).run(cwd=test_dir)

        if self.perform_post:
            logger.debug(self.name + "Post Sim")
            command = Template(self.post).safe_substitute(d)
            if self.is_post_shell:
                utils.shellCommand(command).run(cwd=test_dir)
            else:
                utils.Command(command).run(cwd=test_dir)

        sign_file = test_dir + self.name[:-1] + "_" + self.user_target + "_sign"
        cp = "cat " + test_dir + self.signature + " > " + sign_file
        utils.shellCommand(cp, ensure_absolute_paths=True).run()
        return sign_file

    def make_recursive(self, path):
        cur_path = self.root_dir + "/"
        dirs = (path.replace(self.root_dir, '')).split("/")
        for dir in dirs[:-1]:
            cur_path = cur_path + dir + "/"
            if not os.path.exists(cur_path):
                os.mkdir(cur_path)
        if os.path.exists(cur_path + dirs[-1]):
            shutil.rmtree(cur_path + dirs[-1], ignore_errors=True)
        os.mkdir(cur_path + dirs[-1])

    def compile(self, file, macros, isa):
        logger.debug(self.name + "Compile")
        test = self.root_dir + str(file)
        test_dir = self.work_dir + str(file.replace(self.suite, '')[:-2]) + "/"
        self.make_recursive(test_dir)
        elf = test_dir + str(file.split("/")[-1][:-2]) + '.elf'
        cmd = self.compile_cmd.format(map[isa.lower()],
                                      self.user_abi) + ' ' + test + ' -o ' + elf
        execute = cmd + macros
        utils.Command(execute).run(cwd=test_dir)
        cmd = self.objdump.format(test, self.user_abi) + ' ' + elf
        utils.shellCommand(
            cmd + ' > {}.disass'.format(str(file.split("/")[-1][:-2]))).run(
                cwd=test_dir)
