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
schema = "rips/schema.yaml"

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
    validator = schemaValidator(schema_yaml)
    validator.allow_unknown = True
    common.utils.setup_logging("debug")
    logger = logging.getLogger()
    logger.handlers = []
    ch = logging.StreamHandler()
    ch.setFormatter(common.utils.ColoredFormatter())
    logger.addHandler(ch)
    for file in testpool:
        infile = open(testyamldir+file)
        inp_yaml = yaml.safe_load(infile)
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
