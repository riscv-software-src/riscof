import os
import re
import logging

from cerberus import Validator
import oyaml as yaml

import riscof.utils as utils
from riscof.errors import ValidationError
from .schemaValidator import schemaValidator

logger = logging.getLogger(__name__)


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
        return {'is_hardwired': True, 'hardwired_val': 0}
    else:
        return {'is_hardwired': False}


def nouset():
    '''Function to check and set defaults for all fields which are dependent on 
        the presence of 'U' extension and have a hardwired value of 0.'''
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'is_hardwired': True, 'hardwired_val': 0}
    else:
        return {'is_hardwired': False}


def upieset(doc):
    '''Function to check and set value for upie field in misa.'''
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'is_hardwired': True, 'hardwired_val': 0}
    elif 'UPIE' not in doc.keys():
        return {'is_hardwired': False}
    else:
        return doc['UPIE']


def uieset(doc):
    '''Function to check and set value for uie field in misa.'''
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return {'is_hardwired': True, 'hardwired_val': 0}
    elif 'UIE' not in doc.keys():
        return {'is_hardwired': False}
    else:
        return doc['UIE']


def twset():
    '''Function to check and set value for tw field in misa.'''
    global inp_yaml
    if 'S' not in inp_yaml['ISA'] and 'U' not in inp_yaml['ISA']:
        return {'is_hardwired': True, 'hardwired_val': 0}
    else:
        return {'is_hardwired': False}


def miedelegset():
    '''Function to set "implemented" value for mideleg regisrer.'''
    # return True
    global inp_yaml
    if 'U' not in inp_yaml['ISA']:
        return False
    elif (('U' in inp_yaml['ISA']) and
          not ('N' in inp_yaml['ISA'] or 'S' in inp_yaml['ISA'])):
        return False
    else:
        return True


def mepcset():
    return {
        'range': {
            'rangelist': [[0, int("FFFFFFFF", 16)]],
            'mode': "Unchanged"
        }
    }


def xtvecset():
    return {
        'BASE': {
            'range': {
                'rangelist': [[0, int("3FFFFFFF", 16)]],
                'mode': "Unchanged"
            }
        },
        'MODE': {
            'range': {
                'rangelist': [[0]],
                'mode': "Unchanged"
            }
        }
    }


def simpset():
    global inp_yaml
    if 'S' in inp_yaml['ISA']:
        return True
    else:
        return False


def satpset():
    return {'MODE': {'range': {'rangelist': [[0]]}}}


def add_def_setters(schema_yaml):
    '''Function to set the default setters for various fields in the schema'''
    schema_yaml['mstatus']['schema']['SXL']['schema']['implemented'][
        'default_setter'] = lambda doc: iset()
    schema_yaml['mstatus']['schema']['UXL']['schema']['implemented'][
        'default_setter'] = lambda doc: iset()
    schema_yaml['mstatus']['schema']['TVM'][
        'default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['TSR'][
        'default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['MXR'][
        'default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SUM'][
        'default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SPP'][
        'default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SPIE'][
        'default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['SIE'][
        'default_setter'] = lambda doc: nosset()
    schema_yaml['mstatus']['schema']['UPIE'][
        'default_setter'] = lambda doc: upieset(doc)
    schema_yaml['mstatus']['schema']['UIE'][
        'default_setter'] = lambda doc: uieset(doc)
    schema_yaml['mstatus']['schema']['MPRV'][
        'default_setter'] = lambda doc: nouset()
    schema_yaml['mstatus']['schema']['TW'][
        'default_setter'] = lambda doc: twset()
    schema_yaml['mideleg']['schema']['implemented'][
        'default_setter'] = lambda doc: miedelegset()
    schema_yaml['medeleg']['schema']['implemented'][
        'default_setter'] = lambda doc: miedelegset()
    schema_yaml['mepc']['default_setter'] = lambda doc: mepcset()
    schema_yaml['mtvec']['default_setter'] = lambda doc: xtvecset()
    schema_yaml['stvec']['default_setter'] = lambda doc: xtvecset()
    schema_yaml['satp']['default_setter'] = lambda doc: satpset()
    schema_yaml['stvec']['schema']['implemented'][
        'default_setter'] = lambda doc: simpset()
    schema_yaml['sie']['schema']['implemented'][
        'default_setter'] = lambda doc: simpset()
    schema_yaml['sip']['schema']['implemented'][
        'default_setter'] = lambda doc: simpset()
    schema_yaml['scounteren']['schema']['implemented'][
        'default_setter'] = lambda doc: simpset()
    schema_yaml['sepc']['schema']['implemented'][
        'default_setter'] = lambda doc: simpset()
    schema_yaml['satp']['schema']['implemented'][
        'default_setter'] = lambda doc: simpset()
    return schema_yaml


def check_specs(isa_spec, schema_isa, platform_spec, platform_schema):
    ''' 
        Function to perform ensure that the isa and platform specifications confirm
        to their schemas. The :py:mod:`Cerberus` module is used to validate that the
        specifications confirm to their respective schemas.

        :param isa_spec: The path to the DUT isa specification yaml file.

        :param schema_isa: The path to the yaml file containing the schema 
            describing the isa specs.  

        :param platform_spec: The path to the DUT platform specification yaml file.

        :param schema_platform: The path to the yaml file containing the schema 
            describing the platform specs.
        
        :type isa_spec: str

        :type schema_isa: str

        :type platform_spec: str

        :type schema_platform: str

        :raise ValidationError: It is raised when the specifications violate the 
            schema rules.
    '''
    global inp_yaml

    logger.info('Running RIPS Checker on Input-ISA file')

    foo = isa_spec
    schema = schema_isa
    """
      Read the input-isa foo (yaml file) and validate with schema-isa for feature values
      and constraints
    """
    # Load input YAML file
    logger.info('Loading input file: ' + str(foo))
    inp_yaml = utils.load_yaml(foo)

    # instantiate validator
    logger.info('Load Schema ' + str(schema))
    schema_yaml = utils.load_yaml(schema)

    #Extract xlen
    if "32" in inp_yaml['ISA']:
        xlen = 32
    elif "64" in inp_yaml['ISA']:
        xlen = 64
    elif "128" in inp_yaml['ISA']:
        xlen = 128

    schema_yaml = add_def_setters(schema_yaml)
    validator = schemaValidator(
        schema_yaml,
        xlen=xlen,
    )
    validator.allow_unknown = False
    normalized = validator.normalized(inp_yaml, schema_yaml)

    # Perform Validation
    logger.info('Initiating Validation')
    valid = validator.validate(inp_yaml)
    # xlen = validator.xlen
    # Print out errors
    if valid:
        logger.info('No Syntax errors in Input ISA Yaml. :)')
    else:
        error_list = validator.errors
        logger.error(str(error_list))
        raise ValidationError(
            "Error in ISA Yaml. Refer to logs for more details.")

    file_name_split = foo.split('.')
    output_filename = file_name_split[0] + '_checked.' + file_name_split[1]
    outfile = open(output_filename, 'w')
    logger.info('Dumping out Normalized Checked YAML: ' + output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)

    logger.info('Running RIPS Checker on Input-ISA file')

    foo = platform_spec
    schema = platform_schema
    """
      Read the input-platform foo (yaml file) and validate with schema-platform for feature values
      and constraints
    """
    inputfile = open(foo, 'r')
    schemafile = open(schema, 'r')
    # Load input YAML file
    logger.info('Loading input file: ' + str(foo))
    inp_yaml = utils.load_yaml(foo)

    # instantiate validator
    logger.info('Load Schema ' + str(schema))
    schema_yaml = utils.load_yaml(schema)

    validator = schemaValidator(schema_yaml, xlen=xlen)
    validator.allow_unknown = False
    normalized = validator.normalized(inp_yaml, schema_yaml)
    # print(normalized)
    # Perform Validation
    logger.info('Initiating Validation')
    valid = validator.validate(inp_yaml)

    # Print out errors
    if valid:
        logger.info('No Syntax errors in Input ISA Yaml. :)')
    else:
        error_list = validator.errors
        logger.error(str(error_list))
        raise ValidationError("Error in Platform\
             Yaml. Refer to logs for more details.")

    file_name_split = foo.split('.')
    output_filename = file_name_split[0] + '_checked.' + file_name_split[1]
    outfile = open(output_filename, 'w')
    logger.info('Dumping out Normalized Checked YAML: ' + output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)


def check_environment(env_spec):
    valid = True
    logger.info('Loading input file: ' + str(env_spec))
    input = utils.load_yaml(env_spec)
    logger.info("Checking the environment specs.")
    key_list = input.keys()
    keys = [
        'USER_ENV_DIR', 'USER_LINKER', 'USER_TARGET', 'USER_EXECUTABLE',
        'USER_ABI', 'USER_SIGN', 'RISCV_PREFIX', 'USER_PRE_SIM',
        'USER_POST_SIM', 'BUILD'
    ]
    for x in keys:
        if x not in key_list:
            logger.error(x + " not defined in environment yaml.")
            valid = False
    try:
        temp = input['USER_POST_SIM'].keys()
        if 'is_shell' not in temp:
            logger.error("is_shell not defined in USER_POST_SIM")
            valid = False
        if 'command' not in temp:
            logger.error("command not defined in USER_POST_SIM")
            valid = False
    except KeyError:
        pass

    try:
        temp = input['USER_PRE_SIM'].keys()
        if 'is_shell' not in temp:
            logger.error("is_shell not defined in USER_PRE_SIM")
            valid = False
        if 'command' not in temp:
            logger.error("command not defined in USER_PRE_SIM")
            valid = False
    except KeyError:
        pass

    if not valid:
        raise ValidationError(
            "Error in Environment Yaml. Refer to logs for more details.")
