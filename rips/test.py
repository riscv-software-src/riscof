from cerberus import Validator
import oyaml as yaml
from schemaValidator import *
s = 0
# class riscofValidator(Validator):
#     global s

schemafile=open('schema.yaml','r')
schema=yaml.safe_load(schemafile)
v = schemaValidator(schema)