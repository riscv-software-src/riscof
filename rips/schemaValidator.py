

    def _check_with_mtveccheck(self,field,value):
        '''Function to check whether the inputs in range type in mtvec are valid.'''
        global xlen
        maxv = 2**(xlen)-4
        if not((value['base']<value['bound']) and value['base']<=maxv and value['bound']<=maxv):
            self._error(field,"Invalid values.")
    
    def _check_with_mtvecdist(self,field,value):
        global xlen

        if max(value)>2**(xlen-2)-1:
            self._error(field,"value cant be greater than "+str(2**(xlen)-4))
            self._error(field,"Value cant be greater than "+str(2**(xlen)-4))
    
    def _check_with_midelegcheck(self,field,value):
        if(value['bitmask']['value']>0):
            self._error(field,"No bit can be harwired to 1.")
    
    def _check_with_medelegcheck(self,field,value):
        if(value['bitmask']['base']&int("800",16)>0):
            self._error(field,"11th bit must be hardwired to 0.")
        if(value['bitmask']['value']>0):
            self._error(field,"No bit can be harwired to 1.")