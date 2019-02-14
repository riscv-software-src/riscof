import logging
import argparse
import os
import sys
import subprocess
import operator


class ColoredFormatter(logging.Formatter):                                      
    """                                                                         
        Class to create a log output which is colored based on level.           
    """                                                                         
    def __init__(self, *args, **kwargs):                                        
        super(ColoredFormatter, self).__init__(*args, **kwargs)                 
        self.colors = {                                                         
                'DEBUG' : '\033[94m',                                           
                'INFO'  : '\033[92m',                                           
                'WARNING' : '\033[93m',                                         
                'ERROR' : '\033[91m',                                           
        }                                                                       
                                                                                
        self.reset = '\033[0m'                                                  
                                                                                
    def format(self, record):                                                   
        msg = str(record.msg)                                                   
        level_name = str(record.levelname)                                      
        name = str(record.name)                                                 
        color_prefix = self.colors[level_name]                                  
        return '{0}{1:<9s} - {2:<25s} : {3}{4}'.format(                         
                color_prefix,                                                   
                '[' + level_name + ']',                                         
                name,                                                           
                msg,                                                            
                self.reset)                 



def setup_logging(log_level):                                                   
    """Setup logging                                                            
                                                                                
        Verbosity decided on user input                                         
                                                                                
        Args:                                                                   
            log_level: (str) User defined log level                             
                                                                                
        Returns:                                                                
            None                                                                
    """                                                                         
    numeric_level = getattr(logging, log_level.upper(), None)                   
                                                                                
    if not isinstance(numeric_level, int):                                      
        print("\033[91mInvalid log level passed. Please select from debug | info | warning | error\033[0m")
        sys.exit(1)                                                             
                                                                                
    logging.basicConfig(level = numeric_level)


class SortingHelpFormatter(argparse.HelpFormatter):
    def add_arguments(self, actions):
        actions = sorted(actions, key=operator.attrgetter('option_strings'))
        super(SortingHelpFormatter, self).add_arguments(actions)

def cmdline_args():

    parser = argparse.ArgumentParser(
        formatter_class=SortingHelpFormatter,
        prog="RIFFL Checker",
        description="This Program checks an input YAML for compatibility with\
 RIFFL format"
    )
    parser.add_argument(
        '--input',
        type=str,
        metavar='YAML',
        help='Input YAML file',
        default=None,
        required=True
    )
    
    parser.add_argument(
        '--schema',
        type=str,
        metavar='YAML',
        help='Input Schema file',
        default=None,
        required=True
    )

    parser.add_argument(
        '--verbose',
        action= 'store',
        default='info',
        help='debug | info | warning | error', 
        metavar=""
    )
    return parser
