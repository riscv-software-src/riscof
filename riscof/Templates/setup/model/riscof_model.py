import os
import re
import shutil
import subprocess
import shlex
import logging
import random
import string
from string import Template
import sys

import riscof.utils as utils
import riscof.constants as constants
from riscof.pluginTemplate import pluginTemplate

logger = logging.getLogger()

class spike_simple(pluginTemplate):
    __model__ = "Spike"
    __version__ = "0.5.0"

    def __init__(self, *args, **kwargs):
        sclass = super().__init__(*args, **kwargs)

        config = kwargs.get('config')
        if config is None:
            print("Please enter input file paths in configuration.")
            raise SystemExit
        else:
            self.isa_spec = os.path.abspath(config['ispec'])
            self.platform_spec = os.path.abspath(config['pspec'])
            self.pluginpath=os.path.abspath(config['pluginpath'])

        return sclass

    def initialise(self, suite, work_dir, compliance_env):
        self.work_dir = work_dir
        self.compile_cmd = ''

        # set all the necessary variables like compile command, elf2hex
        # commands, objdump cmds. etc whichever you feel necessary and required
        # for your plugin. 

    def build(self, isa_yaml, platform_yaml):
        ispec = utils.load_yaml(isa_yaml)
        self.isa = ispec["ISA"]

        # based on the validated isa and platform configure your simulator ro
        # build your RTL here

    def runTests(self, testList):
        for file in testList:
            testentry = testList[file]
            test = os.path.join(constants.root, str(file))
            test_dir = testentry['work_dir']

            # compile each test
            # execute each test on simulator/DUT
            # fix signature format if required
            

