import logging
import common.utils as utils
import shutil
import os
import framework.test as test
import importlib
    
def main():
    # Set up the parser
    parser=utils.framework_cmdline_args()
    args=parser.parse_args()

    # Set up the logger 
    utils.setup_logging(args.verbose)
    logger=logging.getLogger()
    logger.handlers = []
    ch=logging.StreamHandler()
    ch.setFormatter(utils.ColoredFormatter())
    logger.addHandler(ch)
    fh=logging.FileHandler('run.log','w')
    logger.addHandler(fh)
    
    work_dir = os.getcwd()+"/work/"
    # suite = os.getcwd()+"/suite/"
    #Creating work directory
    if not os.path.exists(work_dir):
      logger.debug('Creating new work directory: '+work_dir)
      os.mkdir(work_dir)
    else:
      logger.debug('Removing old work directory: '+work_dir)
      shutil.rmtree(work_dir)
      logger.debug('Creating new work directory: '+work_dir)
      os.mkdir(work_dir)

    logger.info("Preparing Models")
    # Gathering Models
    logger.debug("Importing "+args.dut_model+" plugin")
    dut_model = importlib.import_module("plugin."+args.dut_model)
    dut_class = getattr(dut_model,args.dut_model)
    dut = dut_class(name="DUT")
    logger.debug("Importing "+args.base_model+" plugin")
    base_model = importlib.import_module("plugin."+args.base_model)
    base_class = getattr(base_model,args.base_model)
    base = base_class(name="Reference")

    # Setting up models
    if args.dut_env_file is not None:
      logger.debug("Initialising DUT model with "+args.dut_env_file)
      dut.initialise(file=args.dut_env_file,work_dir=work_dir,suite="/suite/")
    else:
      dut.initialise(work_dir=work_dir,suite="/suite/")
    if args.base_env_file is not None:
      logger.debug("Initialising BASE model with "+args.base_env_file)
      base.initialise(file=args.base_env_file,work_dir=work_dir,suite="/suite/")
    else:
      base.initialise(work_dir=work_dir,suite="/suite/")
    #Loading Specs
    ispec=utils.loadyaml(args.dut_isa_spec)
    pspec=utils.loadyaml(args.dut_platform_spec)

    logger.debug("Running Build for DUT")
    dut.build(args.dut_isa_spec,args.dut_platform_spec,ispec['ISA'].lower())
    logger.debug("Running Build for Base")
    base.build(args.dut_isa_spec,args.dut_platform_spec,ispec['ISA'].lower())

    test.execute(dut,base,ispec,pspec)
    # framework.test_execute.load_yaml(args.input)

if __name__ == '__main__':
  main()
