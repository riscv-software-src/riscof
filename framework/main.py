import logging
import common.utils as utils
# import framework.test as test
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
    
    logger.info("Preparing Models")
    # Gathering Models
    logger.debug("Importing "+args.dut_model+" plugin")
    dut_model = importlib.import_module("plugin."+args.dut_model)
    dut_class = getattr(dut_model,args.dut_model)
    dut = dut_class("DUT")
    logger.debug("Importing "+args.base_model+" plugin")
    base_model = importlib.import_module("plugin."+args.base_model)
    base_class = getattr(dut_model,args.base_model)
    base = base_class("Reference")

    # Setting up models
    if args.dut_env_file is not None:
      logger.debug("Initialising DUT model with "+args.dut_env_file)
      dut.initialise_from_file(args.dut_env_file)
    if args.base_env_file is not None:
      logger.debug("Initialising BASE model with "+args.base_env_file)
      base.initialise_from_file(args.base_env_file)

    logger.debug("Running Build for DUT")
    dut.build()
    logger.debug("Running Build for Base")
    base.build()

    #Loading Specs
    ispec=utils.loadyaml(args.dut_isa_spec)
    pspec=utils.loadyaml(args.dut_platform_spec)
    # test.execute(dut,base,ispec,pspec)
    # framework.test_execute.load_yaml(args.input)

if __name__ == '__main__':
  main()
