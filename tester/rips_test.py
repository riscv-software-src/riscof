from rips.schemaValidator import *
import oyaml as yaml
from cerberus import Validator
import common.utils
import logging
import sys
import os
import re

testyamldir = "tester/testyamls/"
testpool =  {
    "misa_valid.yaml": True,
    "misa_invalid.yaml": False
}
schema = "rips/schema-isa.yaml"

def expectedverdict(val):
    if val:
        return "PASS"
    else:
        return "not PASS"

def actualverdict(val):
    if val:
        return "PASSED"
    else:
        return "NOT PASSED"

def test():
    output = ["File Name\tExpected\tResult"]
    schemafile = open(schema, 'r')
    schema_yaml = yaml.safe_load(schemafile)
    common.utils.setup_logging("debug")
    logger = logging.getLogger()
    logger.handlers = []
    ch = logging.StreamHandler()
    ch.setFormatter(common.utils.ColoredFormatter())
    logger.addHandler(ch)
    for file in testpool:
        infile = open(testyamldir+file)
        inp_yaml = yaml.safe_load(infile)
        if "32" in inp_yaml['ISA']:
            xlen = 32
        elif "64" in inp_yaml['ISA']:
            xlen = 64
        elif "128" in inp_yaml['ISA']:
            xlen = 128
        validator = schemaValidator(schema_yaml,xlen=xlen)
        validator.allow_unknown = True
        normalized = validator.normalized(inp_yaml, schema_yaml)
        valid=validator.validate(inp_yaml)
        logger.info("Checking "+str(file))
        try:
            assert valid == testpool[file]
        except AssertionError:
            passed = False
            logger.error(str(file)+ " should "+expectedverdict(testpool[file])+ " but it " + actualverdict(valid))


if __name__ == '__main__':
    test()
