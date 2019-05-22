from cerberus import Validator
import oyaml as yaml
from rips.schemaValidator import *
import common.utils
import logging
import sys
import os
import re

def main():
    # Set up the parser
    parser=common.utils.rips_cmdline_args()
    args=parser.parse_args()

    # Set up the logger 
    common.utils.setup_logging(args.verbose)
    logger=logging.getLogger()
    logger.handlers = []
    ch=logging.StreamHandler()
    ch.setFormatter(common.utils.ColoredFormatter())
    logger.addHandler(ch)

    logger.info('Running RIPS Checker on Input file')

    foo = args.input
    schema = args.schema
    """
      Read the input foo (yaml file) and validate with schema for feature values
      and constraints
    """
    inputfile=open(foo,'r')
    schemafile=open(schema,'r')
    # Load input YAML file
    logger.info('Loading input file: '+str(foo))
    inp_yaml=yaml.safe_load(inputfile)


    # instantiate validator
    logger.info('Load Schema '+str(schema))
    schema_yaml=yaml.safe_load(schemafile)
    validator=schemaValidator(schema_yaml,xlen=32,extensions=0)
    validator.allow_unknown = True
    normalized=validator.normalized(inp_yaml,schema_yaml)

    # Perform Validation
    logger.info('Initiating Validation')
    valid=validator.validate(inp_yaml)
    # Print out errors
    if valid:
      logger.info('No Syntax errors in Input Yaml. :)')
    else:
      error_list = validator.errors
      logger.error(str(error_list))
      # for key in error_list:
      #   logger.error(key+"".join(error_list[key]))
      sys.exit(0)

    logger.info('Performing Additional Checks')

    file_name_split=foo.split('.')
    output_filename=file_name_split[0]+'_checked.'+file_name_split[1]
    outfile=open(output_filename,'w')
    logger.info('Dumping out Normalized Checked YAML: '+output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)

if __name__ == '__main__':
  main()
