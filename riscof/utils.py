import logging
import argparse
import os
import sys
import subprocess
import operator
import shlex
import oyaml as yaml

logger= logging.getLogger(__name__)

def load_yaml(foo):
    with open(foo,"r") as file:
        return yaml.safe_load(file)

class ColoredFormatter(logging.Formatter):                                      
    """                                                                         
        Class to create a log output which is colored based on level.           
    """                                                                         
    def __init__(self, *args, **kwargs):                                        
        super(ColoredFormatter, self).__init__(*args, **kwargs)                 
        self.colors = {                                                         
                'DEBUG' : '\033[94m',                                           
                'INFO'  : '\033[92m',                                           
                'WARNING' : '\033[93m',                                         
                'ERROR' : '\033[91m',                                           
        }                                                                       
                                                                                
        self.reset = '\033[0m'                                                  
                                                                                
    def format(self, record):                                                   
        msg = str(record.msg)                                                   
        level_name = str(record.levelname)                                      
        name = str(record.name)                                                 
        color_prefix = self.colors[level_name]                                  
        return '{0}{1:<9s} : {2}{3}'.format(                         
                color_prefix,                                                   
                '[' + level_name + ']',                                                                                              
                msg,                                                            
                self.reset)                 

def setup_logging(log_level):                                                   
    """Setup logging                                                            
                                                                                
        Verbosity decided on user input                                         
                                                                                
        Args:                                                                   
            log_level: (str) User defined log level                             
                                                                                
        Returns:                                                                
            None                                                                
    """                                                                         
    numeric_level = getattr(logging, log_level.upper(), None)                   
                                                                                
    if not isinstance(numeric_level, int):                                      
        print("\033[91mInvalid log level passed. Please select from debug | info | warning | error\033[0m")
        sys.exit(1)                                                             
                                                                                
    logging.basicConfig(level = numeric_level)


class SortingHelpFormatter(argparse.HelpFormatter):
    def add_arguments(self, actions):
        actions = sorted(actions, key=operator.attrgetter('option_strings'))
        super(SortingHelpFormatter, self).add_arguments(actions)

def execute_command(execute):
    logger.debug(execute)
    x=subprocess.Popen(shlex.split(execute), stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE)
    out, err=x.communicate()
    if(err):
        logger.error(err.rstrip().decode('ascii'))
        sys.exit(0)
    if(out):
        logger.warning(out.rstrip().decode('ascii'))

def execute_sim_command(dir,execute,shell):
    logger.debug(execute)
    if(not shell):
        execute = shlex(dir+execute)
    x=subprocess.Popen(execute,shell=shell, stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE)
    out, err=x.communicate()
    if(err):
        logger.error(err.rstrip().decode('ascii'))
        sys.exit(0)
    if(out):
        logger.warning(out.rstrip().decode('ascii'))

def execute_command_log(execute, logfile):
    execute = execute + '> {}'.format(logfile)
    logger.debug(execute)
    os.system(execute)

def riscof_cmdline_args():
    parser = argparse.ArgumentParser(
        formatter_class = SortingHelpFormatter,
        prog="Riscof",
        description="This program performs the compliance "
    )
    parser.add_argument(
        '--dut_model','-dm',
        type=str,
        metavar='MODEL',
        help='The MODEL whose compliance is to be verified.',
        # required=True
    )
    parser.add_argument(
        '--dut_env_file','-df',
        type=str,
        metavar='FILE',
        help='The FILE for DUT containing necessary environment parameters.',
    )
    parser.add_argument(
        '--base_model','-bm',
        type=str,
        metavar='MODEL',
        default='from_test',
        help='The MODEL whose against which the compliance is verified.'
    )
    parser.add_argument(
        '--base_env_file','-bf',
        type=str,
        metavar='FILE',
        help='The FILE for Base model containing necessary environment parameters.'
    )
    parser.add_argument(
        '--dut_isa_spec','-ispec',
        type=str,
        metavar='YAML',
        help='The YAML which contains the ISA specs of the DUT.',
        required=True
    )
    parser.add_argument(
        '--dut_platform_spec','-pspec',
        type=str,
        metavar='YAML',
        help='The YAML which contains the Platfrorm specs of the DUT.',
        required=True
    )
    parser.add_argument(
        '--dut_env_yaml','-eyaml',
        type=str,
        metavar='YAML',
        help='The YAML which contains the Platfrorm specs of the DUT.',
    )
    parser.add_argument(
        '--verbose',
        action= 'store',
        default='info',
        help='debug | info | warning | error', 
        metavar=""
    )
    return parser

def framework_cmdline_args():
    parser = argparse.ArgumentParser(
        formatter_class = SortingHelpFormatter,
        prog="Framework",
        description="This Program takes in the DUT spec and the comparision model\
 and tests compliance."
    )
    parser.add_argument(
        '--dut_model','-dm',
        type=str,
        metavar='MODEL',
        help='The MODEL whose compliance is to be verified.',
        required=True
    )
    parser.add_argument(
        '--dut_env_file','-df',
        type=str,
        metavar='FILE',
        help='The FILE for DUT containing necessary environment parameters.',
        required=True
    )
    parser.add_argument(
        '--base_model','-bm',
        type=str,
        metavar='MODEL',
        help='The MODEL whose against which the compliance is verified.',
        required=True
    )
    parser.add_argument(
        '--base_env_file','-bf',
        type=str,
        metavar='FILE',
        help='The FILE for Base model containing necessary environment parameters.'
    )
    parser.add_argument(
        '--dut_isa_spec','-ispec',
        type=str,
        metavar='YAML',
        help='The normalised YAML which contains the ISA specs of the DUT.',
        required=True
    )
    parser.add_argument(
        '--dut_platform_spec','-pspec',
        type=str,
        metavar='YAML',
        help='The normalised YAML which contains the Platfrorm specs of the DUT.',
        required=True
    )
    parser.add_argument(
        '--verbose',
        action= 'store',
        default='info',
        help='debug | info | warning | error', 
        metavar=""
    )
    return parser
    

def rips_cmdline_args():

    parser = argparse.ArgumentParser(
        formatter_class=SortingHelpFormatter,
        prog="RIPS Checker",
        description="This Program checks an input YAML for compatibility with\
 RIPS format"
    )
    parser.add_argument(
        '--input_isa','-ii',
        type=str,
        metavar='YAML',
        help='Input YAML file containing ISA specs.',
        default=None,
        required=True
    )
    
    parser.add_argument(
        '--input_platform','-pi',
        type=str,
        metavar='YAML',
        help='Input YAML file containing platform specs.',
        default=None,
        required=True
    )

    parser.add_argument(
        '--input_environment','-ei',
        type=str,
        metavar='YAML',
        help='Input YAML file containing environment specs.',
        default=None,
    )

    parser.add_argument(
        '--schema_isa','-is',
        type=str,
        metavar='YAML',
        help='Input YAML file containing the schema for ISA.',
        default=None,
        required=True
    )

    parser.add_argument(
        '--schema_platform','-ps',
        type=str,
        metavar='YAML',
        help='Input YAML file containing the schema for Platform.',
        default=None,
        required=True
    )

    parser.add_argument(
        '--verbose',
        action= 'store',
        default='info',
        help='debug | info | warning | error', 
        metavar=""
    )
    return parser

def fw_cmdline_args():

    parser = argparse.ArgumentParser(
        formatter_class=SortingHelpFormatter,
        prog="Compliance Framework",
        description="This program will run the tests from RISC-V compliance \
suite based on the standard-input yaml file"
    )
    parser.add_argument(
        '--input',
        type=str,
        metavar='YAML',
        help='Input Standard YAML file',
        default=None,
        required=True
    )

    parser.add_argument(
        '--verbose',
        action= 'store',
        default='info',
        help='debug | info | warning | error', 
        metavar=""
    )
    return parser
