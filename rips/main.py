from cerberus import Validator
import oyaml as yaml
from rips.schemaValidator import *
import common.utils
import logging
import sys
import os
import re

def iset():
    '''Function to check and set defaults for all "implemented" fields which are dependent on 
        the xlen.'''
    global inp_yaml
    if '32' in inp_yaml['ISA']:
        return False
    else:
        return True

def nosset():
    '''Function to check and set defaults for all fields which are dependent on 
        the presence of 'S' extension and have a hardwired value of 0.'''
    global inp_yaml
    if 'S' not in inp_yaml['ISA']:
        return {'is_hardwired':True,'hardwired_val':0}
    else:
        return {'is_hardwired':False}
    
def nouset():
    '''Function to check and set defaults for all fields which are dependent on 
        the presence of 'U' extension and have a hardwired value of 0.'''
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'is_hardwired':True,'hardwired_val':0}
    else:
        return {'is_hardwired':False}

def upieset(doc):
    '''Function to check and set value for upie field in misa.'''
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'is_hardwired':True,'hardwired_val':0}
    elif 'UPIE' not in doc.keys():
        return {'is_hardwired':False}
    else:
        return doc['UPIE']

def uieset(doc):
    '''Function to check and set value for uie field in misa.'''
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'is_hardwired':True,'hardwired_val':0}
    elif 'UIE' not in doc.keys():
        return {'is_hardwired':False}
    else:
        return doc['UIE']

def twset():
    '''Function to check and set value for tw field in misa.'''
    global inp_yaml
    if 'S' not in inp_yaml['ISA'] and 'U' not in inp_yaml['ISA']:
        return {'is_hardwired':True,'hardwired_val':0}
    else:
        return {'is_hardwired':False}

def miedelegset():
    '''Function to set "implemented" value for mideleg regisrer.'''
    # return True
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return False
    elif (('U' in inp_yaml['ISA']) and not ('N' in inp_yaml['ISA'] or 'S' in inp_yaml['ISA'])):
        return False
    else:
        return True

def mepcset():
    return {'range':{'rangelist':[[0,int("FFFFFFFF",16)]],'mode':"UnChgd"}}
def add_def_setters(schema_yaml):
    '''Function to set the default setters for various fields in the schema'''
    # schema_yaml['misa']['schema']['Extensions']['schema']['readonly']['default_setter'] = lambda doc: extreaddefset()
    schema_yaml['mstatus']['schema']['SXL']['schema']['implemented']['default_setter'] = lambda doc: iset()
    schema_yaml['mstatus']['schema']['UXL']['schema']['implemented']['default_setter'] = lambda doc: iset()
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
    schema_yaml['mideleg']['schema']['implemented']['default_setter'] = lambda doc:miedelegset()
    schema_yaml['medeleg']['schema']['implemented']['default_setter'] = lambda doc:miedelegset()
    schema_yaml['mepc']['default_setter'] = lambda doc: mepcset()
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

    logger.info('Running RIPS Checker on Input-ISA file')

    foo = args.input_isa
    schema = args.schema_isa
    """
      Read the input-isa foo (yaml file) and validate with schema-isa for feature values
      and constraints
    """
    inputfile = open(foo, 'r')
    schemafile = open(schema, 'r')
    # Load input YAML file
    logger.info('Loading input file: '+str(foo))
    inp_yaml = yaml.safe_load(inputfile)

    # instantiate validator
    logger.info('Load Schema '+str(schema))
    schema_yaml = yaml.safe_load(schemafile)
    
    #Extract xlen
    if "32" in inp_yaml['ISA']:
            xlen = 32
    elif "64" in inp_yaml['ISA']:
        xlen = 64
    elif "128" in inp_yaml['ISA']:
        xlen = 128

    schema_yaml=add_def_setters(schema_yaml)
    validator = schemaValidator(schema_yaml,xlen=xlen)
    validator.allow_unknown = True
    normalized = validator.normalized(inp_yaml, schema_yaml)
    
    # Perform Validation
    logger.info('Initiating Validation')
    valid=validator.validate(inp_yaml)
    # xlen = validator.xlen
    # Print out errors
    if valid:
        logger.info('No Syntax errors in Input ISA Yaml. :)')
    else:
        error_list = validator.errors
        logger.error(str(error_list))
        sys.exit(0)

    file_name_split=foo.split('.')
    output_filename=file_name_split[0]+'_checked.'+file_name_split[1]
    outfile=open(output_filename,'w')
    logger.info('Dumping out Normalized Checked YAML: '+output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)

    logger.info('Running RIPS Checker on Input-ISA file')

    foo = args.input_platform
    schema = args.schema_platform
    """
      Read the input-platform foo (yaml file) and validate with schema-platform for feature values
      and constraints
    """
    inputfile = open(foo, 'r')
    schemafile = open(schema, 'r')
    # Load input YAML file
    logger.info('Loading input file: '+str(foo))
    inp_yaml = yaml.safe_load(inputfile)

    # instantiate validator
    logger.info('Load Schema '+str(schema))
    schema_yaml = yaml.safe_load(schemafile)

    validator = schemaValidator(schema_yaml,xlen=xlen)
    validator.allow_unknown = True
    normalized = validator.normalized(inp_yaml, schema_yaml)
    # print(normalized)
    # Perform Validation
    logger.info('Initiating Validation')
    valid=validator.validate(inp_yaml)
    
    # Print out errors
    if valid:
        logger.info('No Syntax errors in Input ISA Yaml. :)')
    else:
        error_list = validator.errors
        logger.error(str(error_list))
        sys.exit(0)

    file_name_split=foo.split('.')
    output_filename=file_name_split[0]+'_checked.'+file_name_split[1]
    outfile=open(output_filename,'w')
    logger.info('Dumping out Normalized Checked YAML: '+output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)

    foo = args.input_environment
    if(foo is not None):
        """
          Read the input-environment foo (yaml file) and perform checks.
        """
        inputfile = open(foo, 'r')
        logger.info('Loading input file: '+str(foo))
        inp_yaml = yaml.safe_load(inputfile)
        logger.info("Checking the environment specs.")
        environment_check(inp_yaml)

def environment_check(input):
    logger = logging.getLogger(__name__)
    key_list = input.keys()
    keys = ['USER_ENV_DIR', 'USER_LINKER', 'USER_TARGET', 'USER_EXECUTABLE', 'USER_ABI', 'USER_SIGN', 'RISCV_PREFIX', 'USER_PRE_SIM', 'USER_POST_SIM', 'BUILD']
    for x in keys:
        if x not in key_list:
            logger.error(x+" not defined in environment yaml.")
    try:
        temp = input['USER_POST_SIM'].keys()
        if 'is_shell' not in temp:
            logger.error("is_shell not defined in USER_POST_SIM")
        if 'command' not in temp:
            logger.error("command not defined in USER_POST_SIM")
    except KeyError:
        pass

    try:
        temp = input['USER_PRE_SIM'].keys()
        if 'is_shell' not in temp:
            logger.error("is_shell not defined in USER_PRE_SIM")
        if 'command' not in temp:
            logger.error("command not defined in USER_PRE_SIM")
    except KeyError:
        pass

if __name__ == '__main__':
    main()

