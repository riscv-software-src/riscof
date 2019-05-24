from cerberus import Validator
import oyaml as yaml
from rips.schemaValidator import *
import common.utils
import logging
import sys
import os
import re


# class exset(yaml.YAMLObject):
#   yaml_tag = '!exset'

#   def __init__(self, name):
#     self.name = eval(name)


def extreaddefset(doc):
    global inp_yaml
    # print("kk")
    # print(inp_yaml['misa']['Extensions']['bitmask']['base'])
    if inp_yaml['misa']['Extensions']['bitmask']['base'] > 0:
        return False
    else:
        return True

def sset(doc):
    global inp_yaml
    if 'S' in inp_yaml['ISA']:
        return True
    else:
        return False

def uset(doc):
    # global extensions
    global inp_yaml
    if 'U' in inp_yaml['ISA']:
        return True
    else:
        return False

def add_def_setters(schema_yaml):
    # print(schema_yaml['misa'])
    schema_yaml['misa']['schema']['Extensions']['schema']['readonly']['default_setter'] = lambda doc: extreaddefset(doc)
    schema_yaml['mstatus']['schema']['SXL']['schema']['implemented']['default_setter'] = lambda doc: sset(doc)
    schema_yaml['mstatus']['schema']['UXL']['schema']['implemented']['default_setter'] = lambda doc: uset(doc)
    return schema_yaml

def main():
    global inp_yaml
    # Set up the parser
    parser = common.utils.rips_cmdline_args()
    args = parser.parse_args()

    # Set up the logger
    common.utils.setup_logging(args.verbose)
    logger = logging.getLogger()
    logger.handlers = []
    ch = logging.StreamHandler()
    ch.setFormatter(common.utils.ColoredFormatter())
    logger.addHandler(ch)

    logger.info('Running RIPS Checker on Input file')

    foo = args.input
    schema = args.schema
    """
      Read the input foo (yaml file) and validate with schema for feature values
      and constraints
    """
    inputfile = open(foo, 'r')
    schemafile = open(schema, 'r')
    # Load input YAML file
    logger.info('Loading input file: '+str(foo))
    inp_yaml = yaml.safe_load(inputfile)

    # instantiate validator
    logger.info('Load Schema '+str(schema))
    # yaml.add_path_resolver('!exset',"lambda doc: extreaddefset(doc)")
    schema_yaml = yaml.safe_load(schemafile)
    
    schema_yaml=add_def_setters(schema_yaml)
    validator = schemaValidator(schema_yaml)
    validator.allow_unknown = True
    normalized = validator.normalized(inp_yaml, schema_yaml)
    # print(normalized)
    # Perform Validation
    logger.info('Initiating Validation')
    valid=validator.validate(inp_yaml)
    
    # Print out errors
    if valid:
        logger.info('No Syntax errors in Input Yaml. :)')
    else:
        error_list = validator.errors
        logger.error(str(error_list))
        sys.exit(0)

    logger.info('Performing Additional Checks')

    file_name_split = foo.split('.')
    output_filename = file_name_split[0]+'_checked.'+file_name_split[1]
    outfile = open(output_filename, 'w')
    logger.info('Dumping out Normalized Checked YAML: '+output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)


if __name__ == '__main__':
    main()

