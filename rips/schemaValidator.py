from cerberus import Validator
import logging
logger= logging.getLogger(__name__)
# Custom validator for schema having the custom rules necessary for implementation and checks
class schemaValidator(Validator):
    def __init__(self, *args, **kwargs):
        super(schemaValidator, self).__init__(*args, **kwargs)
    def _check_with_capture_isa_specifics(self,field,value):
        extension_enc = "00000000000000000000000000"
        if "32" in value:
            self.xlen = 32
            ext = value[4:]
        elif "64" in value:
            self.xlen = 64
            ext = value[4:]
        elif "128" in value:
            self.xlen = 128
            ext = value[5:]
        else:
            self._error(field,"Invalid width in ISA.")
        if any(x in value for x in "EI"):
            if 'D' in value and not 'F' in value:
                self._error(field,"D cannot exist without F")
            if 'Q' in value and not all(x in value for x in "FD"):
                self._error(field,"D cannot exist without F and D")
            if 'Zicsr' in value and not all(x in value for x in "FD"):
                self._error(field,"D cannot exist without F and D")
            if 'Zam' in value and not 'A' in value:
                self._error(field,"Zam cannot exist without A")
            if 'N' in value and not 'U' in value:
                self._error(field,"N cannot exist without U")
            if 'S' in value and not 'U' in value:
                self._error(field,"S cannot exist without U")
        else:
            self._error(field,"Neither of E or I extensions are present.")
        for x in "ACDEFGIJLMNPQSTUVXZ":
            if(x in ext):
                extension_enc[26-int(x)-int('A')] = '1'
        self.extenstions = int(extension_enc,2)
    def _check_with_max_length(self,field,value):
        if max(value) > (2**self.xlen)-1:
            self._error(field,"Max value is greater than xlen.")
    def _check_with_len_check(self,field,value):
        if max(value) > self.xlen/32:
            self._error(field,"Max width allowed is greater than xlen.")
    def _check_with_hart_check(self,field,value):
        if max(value) > self.xlen/32:
            self._error(field,"Max width allowed is greater than xlen.")
        if 0 not in value:
            self.error(field,"Atleast one hart must have id as 0.")
    def _check_with_ext_check(self,field,value):
        int = value['base'] ^ value['value'] ^ self.extenstions