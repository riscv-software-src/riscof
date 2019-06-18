import logging

import riscof.rips as rips
import riscof.framework as framework
import riscof.utils as utils
import riscof.constants as constants
from riscof.errors import *

def main():
    # Set up the parser
    parser = utils.riscof_cmdline_args()
    args = parser.parse_args()

    # Set up the logger
    utils.setup_logging(args.verbose)
    logger = logging.getLogger()
    logger.handlers = []
    ch = logging.StreamHandler()
    ch.setFormatter(utils.ColoredFormatter())
    logger.addHandler(ch)
    fh=logging.FileHandler('run.log','w')
    logger.addHandler(fh)

    #Run rips on inputs
    isa_file = args.dut_isa_spec
    platform_file = args.dut_platform_spec

    rips.spec_check(isa_file,constants.isa_schema,platform_file,constants.platform_schema)

    env_yaml = args.dut_env_yaml

    if env_yaml:
        rips.environment_check(env_yaml)
        env_file=env_yaml
    else:
        env_file=args.dut_env_file
    
    file_name_split = isa_file.split('.')
    isa_file=file_name_split[0]+'_checked.'+file_name_split[1]

    file_name_split = platform_file.split('.')
    platform_file=file_name_split[0]+'_checked.'+file_name_split[1]

    framework.run(args.dut_model,env_file,args.base_model,args.base_env_file,isa_file,platform_file)
    

if __name__ == "__main__":
    try:
        main()
    except ValidationError:
        exit()