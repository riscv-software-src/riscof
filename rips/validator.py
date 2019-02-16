"""
  Validation functions for input yaml file
"""

from cerberus import Validator
import oyaml as yaml
import sys
import os
import re
import logging

logger= logging.getLogger(__name__)

def specific_checks(foo):

    xlen = int(foo['ISA'][:4][2:])
    ######################### ISA field checks #########################
    if 'D' in foo['ISA'] and 'F' not in foo['ISA']:
        logger.error('D cannot be supported without F')
        sys.exit(0)
    if 'Q' in foo['ISA'] and ('F' not in foo['ISA'] or 'D' not in foo['ISA']):
        logger.error('Q cannot be supported without D/F')
        sys.exit(0)
    if 'N' in foo['ISA'] and 'U' not in foo['ISA']:
        logger.error('N cannot be supported without U')
        sys.exit(0)
    if 'S' in foo['ISA'] and 'U' not in foo['ISA']:
        logger.error('S canoot be supported without U')
        sys.exit(0)
    #########################  MISA field checks #######################
    
    if len(foo['MISA_MXL'])==0:
        if xlen==32:
            foo['MISA_MXL']= [1]
        elif xlen==64:
            foo['MISA_MXL']= [2]
        else:
            foo['MISA_MXL']= [3]

    if 2**(max(foo['MISA_MXL'])+4) != xlen:
        logger.error('For max MXL value of '+str(max(foo['MISA_MXL']))+' XLEN\
 should be '+str(2**(max(foo['MISA_MXL'])+4))+' but is set as '+
        str(xlen))
        sys.exit(0)

    if 1 in foo['MISA_D'] and 1 not in foo['MISA_F']:
        logger.error('MISA_D set without setting MISA_F')
        sys.exit(0)
    
    if 1 in foo['MISA_Q'] and 1 not in foo['MISA_D']:
        logger.error('MISA_Q set without setting MISA_D')
        sys.exit(0)

    if 1 in foo['MISA_N'] and 1 not in foo['MISA_U']:
        logger.error('MISA_N set without setting MISA_U')
        sys.exit(0)

    if 1 in foo['MISA_S'] and 1 not in foo['MISA_U']:
        logger.error('MISA_S set without setting MISA_U')
        sys.exit(0)

    ####################### HARTIDs field checks #########################
    # Atleast one of the HARTIDs should be 0
    if 0 not in foo['Hartids']:
        logger.error('Atleast one of the HartIDs should be 0')
        sys.exit(0)
    
    ####################### MSTATUS field checks #########################

    # if MISA_S is not set then SXL should be empty
    if not (foo['MISA_S']) and (len(foo['MSTATUS_SXL'])!=0):
        logger.error('If supervisor is not supported, then MSTATUS_SXL should\
 be empty i.e not defined')
        sys.exit(0)
    # in RV32 systems SXL should be empty
    if xlen==32 and  (len(foo['MSTATUS_SXL'])!=0):
        logger.error('For RV32 systems, MSTATUS_SXL field should not exist')
        sys.exit(0)
    
    # if MISA_U is not set then the UXL field should be empty
    if not (foo['MISA_U']) and (len(foo['MSTATUS_UXL'])!=0):
        logger.error('If user is not supported, then MSTATUS_UXL should\
 be empty i.e not defined')
        sys.exit(0)

    # in RV32 systems UXL should be empty
    if xlen==32 and  (len(foo['MSTATUS_UXL'])!=0):
        logger.error('For RV32 systems, MSTATUS_UXL field should not exist')
        sys.exit(0)
    
    if len(foo['MSTATUS_SXL'])==0:
        if '32' in foo['ISA']:
            foo['MSTATUS_SXL']= [0]
        elif '64' in foo['ISA']:
            foo['MSTATUS_SXL']= [2]
        else:
            foo['MSTATUS_SXL']= [3]

    
    # Max supported width SXL <= XLEN
    if len(foo['MSTATUS_SXL'])!=0 and 2**(max(foo['MSTATUS_SXL'])+4) > xlen:
        logger.error('Max MSTATUS_SXL value exceeds the encoding for XLEN: '+ 
        str(xlen))
        sys.exit(0)
   
    if len(foo['MSTATUS_UXL'])==0:
        if '32' in foo['ISA']:
            foo['MSTATUS_UXL']= [0]
        elif '64' in foo['ISA']:
            foo['MSTATUS_UXL']= [2]
        else:
            foo['MSTATUS_UXL']= [3]
    
    # Max supported width in UXL <= XLEN
    if len(foo['MSTATUS_UXL'])!=0 and 2**(max(foo['MSTATUS_UXL'])+4) > xlen:
        logger.error('Max MSTATUS_UXL value exceeds the encoding for XLEN: '+ 
        str(xlen))
        sys.exit(0)

    ####################### MIDELEG field checks #########################
    # if only Machine and User supported then MIDELEG should exist only if
    # MISA_N is set
    if foo['MISA_U'] and not foo['MISA_S'] and not foo['MISA_N'] and \
    foo['MIDELEG']!=0 :
        logger.error('Since only Machine and User modes are supported, MIDELEG \
        can only be supported if MISA_N is supported')
        sys.exit(0)
    
    ####################### MEDELEG field checks #########################

    # if only Machine and User supported then MEDELEG should exist only if
    # MISA_N is set
    if foo['MISA_U'] and not foo['MISA_S'] and not foo['MISA_N'] and \
    foo['MEDELEG']!=0 :
        logger.error('Since only Machine and User modes are supported, MEDELEG \
        can only be supported if MISA_N is supported')
        sys.exit(0)

    # Machine call exception cannot be delegated therefore the MEDELEG bit
    # should be 0
    if (foo['MEDELEG'] & 0x800)!=0:
        logger.error('Machine call from M-mode cannot be delegated')
        sys.exit(0)

def load_and_validate(foo, schema):
  
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
    validator=Validator(schema_yaml)
    validator.allow_unknown = True
    normalized=validator.normalized(inp_yaml,schema_yaml)

    # Perform Validation
    logger.info('Initiating Validation')
    valid=validator.validate(inp_yaml)
    # Print out errors
    if valid:
      logger.info('No Syntax errors in Input Yaml. :)')
    else:
      logger.error(validator.errors)
      sys.exit(0)

    logger.info('Performing Additional Checks')
    
    specific_checks(normalized)

    file_name_split=foo.split('.')
    output_filename=file_name_split[0]+'_checked.'+file_name_split[1]
    outfile=open(output_filename,'w')
    logger.info('Dumping out Normalized Checked YAML: '+output_filename)
    yaml.dump(normalized, outfile, default_flow_style=False, allow_unicode=True)

