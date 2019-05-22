from cerberus import Validator
# Custom validator for schema having the custom rules necessary for implementation and checks
class schemaValidator(Validator):
    def __init__(self, *args, **kwargs):
        super(schemaValidator, self).__init__(*args, **kwargs)
    def _check_with_set_xlen(self,field,value):
        self.xlen = int(value)
    def _check_with_capture_isa_specifics(self,field,value):
        if not str(self.xlen) in value:
            self._error(field,"Incompatible ISA and max Register width.")
    def _check_with_max_length(self,field,value):
        if max(value) > (2**self.xlen)-1:
            self._error(field,"Max value is greater than xlen.")
    def _check_with_len_max(self,field,value):
        if max(value) > self.xlen/32:
            self._error(field,"Max width allowed is greater than xlen.")
    def _check_with_hart_check(self,field,value):
        if max(value) > self.xlen/32:
            self._error(field,"Max width allowed is greater than xlen.")
        if 0 not in value:
            self.error(field,"Atleast one hart must have id as 0.")
    