import logging
import rips.validator
import rips.utils
    
def main():
    # Set up the parser
    parser=rips.utils.cmdline_args()
    args=parser.parse_args()

    # Set up the logger 
    rips.utils.setup_logging(args.verbose)
    logger=logging.getLogger()
    logger.handlers = []
    ch=logging.StreamHandler()
    ch.setFormatter(rips.utils.ColoredFormatter())
    logger.addHandler(ch)

    logger.info('Running RIPS Checker on Input file')

    # Initiate check
    rips.validator.load_and_validate(args.input, args.schema)

if __name__ == '__main__':
  main()
