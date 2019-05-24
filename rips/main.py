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


def extreaddefset():
    global inp_yaml
    # print("kk")
    # print(inp_yaml['misa']['Extensions']['bitmask']['base'])
    if inp_yaml['misa']['Extensions']['bitmask']['base'] > 0:
        return False
    else:
        return True

def sset():
    global inp_yaml
    if 'S' in inp_yaml['ISA']:
        return True
    else:
        return False

def uset():
    # global extensions
    global inp_yaml
    if 'U' in inp_yaml['ISA']:
        return True
    else:
        return False

def nosset():
    global inp_yaml
    if 'S' not in inp_yaml['ISA']:
        return {'readonly':True,'hardwired':0}
    else:
        return {'readonly':False}
    
def nouset():
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'readonly':True,'hardwired':0}
    else:
        return {'readonly':False}

def upieset(doc):
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'readonly':True,'hardwired':0}
    elif 'UPIE' not in doc.keys():
        return {'readonly':False}
    else:
        return doc['UPIE']

def uieset(doc):
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'readonly':True,'hardwired':0}
    elif 'UPIE' not in doc.keys():
        return {'readonly':False}
    else:
        return doc['UPIE']

def twset():
    global inp_yaml
    if 'S' not in inp_yaml['ISA'] and 'U' not in inp_yaml['ISA']:
        return {'readonly':True,'hardwired':0}
    else:
        return {'readonly':False}

def add_def_setters(schema_yaml):
    # print(schema_yaml['misa'])
    schema_yaml['misa']['schema']['Extensions']['schema']['readonly']['default_setter'] = lambda doc: extreaddefset()
    schema_yaml['mstatus']['schema']['SXL']['schema']['implemented']['default_setter'] = lambda doc: sset()
    schema_yaml['mstatus']['schema']['UXL']['schema']['implemented']['default_setter'] = lambda doc: uset()
    schema_yaml['mstatus']['schema']['TVM']['default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['TSR']['default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['MXR']['default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SUM']['default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SPP']['default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SPIE']['default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SIE']['default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['UPIE']['default_setter'] = lambda doc: upieset(doc)
    schema_yaml['mstatus']['schema']['UIE']['default_setter'] = lambda doc: uieset(doc)
    schema_yaml['mstatus']['schema']['MPRV']['default_setter'] = lambda doc: nouset()
    schema_yaml['mstatus']['schema']['TW']['default_setter'] = lambda doc: twset()
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

    file_name_split=foo.split('.')
    output_filename=file_name_split[0]+'_checked.'+file_name_split[1]
    outfile=open(output_filename,'w')
    logger.info('Dumping out Normalized Checked YAML: '+output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)


if __name__ == '__main__':
    main()

