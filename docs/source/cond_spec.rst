.. _cond_spec:

**************************
Framework directives(WIP)
**************************

This section describes the format for the conditions to be followed while writing *_DSTR* for the *RVTEST_CASE_START* macro. Each of the statements ends with a ';' .

A keylist is a string of '>' separated words(keys) which is used to navigate the supplied specs. The schema may be used to specify them. Only valid keys and their combinations are allowed(as present in the scema).

There are two types of valid statements allowed.

1. "check" statements 

    .. code-block:: none

        check condition;

    These statements get translated into the condtions which need to be true for the part to be enabled.
    The condition can be structured in one of the following allowed ways.
    
    * keylist:=value

        The keylist specifies the path to the field whose value needs to be checked. 
        The value is the value against which the entry in the specs is checked against.
        It is allowed for the value to be regular expression also. 
        In which case it should be specified as *regex("expression")*
    
    * keylist=key

        The keylist specifies the path to the field whose keys needs to be checked. 
        The key is the key whose presence needs to be checked in the field specified by the keylist.

2. "define" statements

    .. code-block:: none
        
        define macro(=value/keylist);

    These statements specify which macros to be defined for the part to run and their values(optional).
    The macro specifies the name of the macro.
    A keylist specifying the path of the field whose value has to be passed as the value of the macro can also be given.
