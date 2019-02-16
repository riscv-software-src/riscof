import logging
import rips.validator
import common.utils
    
def main():
    # Set up the parser
    parser=common.utils.cmdline_args()
    args=parser.parse_args()

    # Set up the logger 
    common.utils.setup_logging(args.verbose)
    logger=logging.getLogger()
    logger.handlers = []
    ch=logging.StreamHandler()
    ch.setFormatter(common.utils.ColoredFormatter())
    logger.addHandler(ch)

    logger.info('Running RIPS Checker on Input file')

    # Initiate check
    rips.validator.load_and_validate(args.input, args.schema)

if __name__ == '__main__':
  main()
