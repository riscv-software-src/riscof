import logging
import common.utils
import framework.test_execute
    
def main():
    # Set up the parser
    parser=common.utils.fw_cmdline_args()
    args=parser.parse_args()

    # Set up the logger 
    common.utils.setup_logging(args.verbose)
    logger=logging.getLogger()
    logger.handlers = []
    ch=logging.StreamHandler()
    ch.setFormatter(common.utils.ColoredFormatter())
    logger.addHandler(ch)
    fh=logging.FileHandler('run.log','w')
    logger.addHandler(fh)

    framework.test_execute.load_yaml(args.input)

if __name__ == '__main__':
  main()
