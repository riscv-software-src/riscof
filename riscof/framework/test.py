import logging
import re
import sys
import os
from pathlib import Path
import difflib
import ast
import random
from datetime import datetime

from riscof.utils import yaml
import riscof.utils as utils
import riscof.constants as constants
from riscv_config.warl import warl_interpreter

logger = logging.getLogger(__name__)


def compare_signature(file1, file2):
    '''
        Function to check whether two signature files are equivalent. This funcion uses the
        :py:mod:`difflib` to perform the comparision and obtain the difference.

        :param file1: The path to the first signature.

        :param file2: The path to the second signature.

        :type file1: str

        :type file2: str

        :return: A string indicating whether the test "Passed" (if files are the same)
            or "Failed" (if the files are different) and the diff of the files.

    '''
    if not os.path.exists(file1) :
        logger.error('Signature file : ' + file1 + ' does not exist')
        sys.exit(1)
    file1_lines = open(file1, "r").readlines()
    res = ("".join(
        difflib.unified_diff(file1_lines,open(file2, "r").readlines(), file1, file2))).strip()
    if res == "":
        if len(file1_lines)==0:
            return 'Failed', '---- \nBoth FIles empty\n'
        else:
            status = 'Passed'
    else:
        status = 'Failed'
    return status, res

def get_node(spec,node):
    keys = node.split(">")
    for key in keys:
        spec = spec[key]
    return spec

def eval_cond(condition, spec):
    '''
        Function to evaluate the "check" statements in the database entry and return the macro string.

        :param condition: The "check" statement in the test which needs to be evaluated.

        :param spec: The specifications of the DUT.

        :type condition: str

        :type spec: dict

        :return: A boolean value specifying whether the condition is satisfied by
            the given specifications or not.
    '''
    condition = (condition.replace("check", '')).strip()
    if 'writable' in condition:
        parts = condition.split("=")
        func_args = ((parts[0].replace("writable(","")).replace(")","")).split(",")
        if writable(spec,int(func_args[0]),func_args[1]) == eval(parts[1]):
            return True
        else:
            return False
    elif 'islegal' in condition:
        func_args = ((condition.replace("islegal(","")).replace(")","")).split(",")
        try:
            spec = get_node(spec,func_args[2])
        except KeyError:
            return False
        if 'warl' in spec['type']:
            warl = warl_interpreter(spec['type']['warl'])
            deps = warl.dependencies()
            return warl.islegal(func_args[0],eval(func_args[1]))
        return False
    elif ':=' in condition:
        temp = condition.split(":=")
        try:
            spec = get_node(spec,temp[0])
        except KeyError:
            return False
        if "regex(" in temp[1]:
            exp = temp[1].replace("regex(", "r\"")[:-1] + ("\"")
            x = re.match(eval(exp), spec)
            if x is None:
                return False
            else:
                return True
        elif ast.literal_eval(temp[1]) == spec:
            return True
        else:
            return False
    elif '=' in condition:
        temp = condition.split("=")
        try:
            spec = get_node(spec,temp[0])
        except KeyError:
            return False
        if temp[1] in spec:
            return True
        else:
            return False

def getlegal(spec,dep_vals,num,node):
    end_vals = []
    try:
        spec = get_node(spec,node)
    except KeyError:
        return []
    if 'warl' in spec['type']:
        warl = (warl_interpreter(spec['type']['warl']))
        deps = warl.dependencies()
        vals = warl.legal(eval(dep_vals))
        end_vals = [ hex(int(li[0],base=16)<<spec['lsb']) if '0x' in li[0] else hex(int(li[0])<<spec['lsb']) for li in vals ]
    elif 'ro_constant' in spec['type']:
        end_vals = [hex(spec['type']['ro_constant'][0]<<spec['lsb'])]
    num = int(num)
    if num < len(end_vals):
        end_vals = end_vals[:num]
    else:
        end_vals.extend([end_vals[-1]]*(num-len(end_vals)))
    return end_vals

def writable(spec,bit,node):
    try:
        spec = get_node(spec,node)
    except KeyError:
        return False

    bit_width = spec['msb']-spec['lsb']+1
    if bit>bit_width:
        return False
    if 'warl' in spec['type']:
        warl = (warl_interpreter(spec['type']['warl']))
        deps = warl.dependencies()
        vals = warl.legal([])
        legal = [ bin(int(li[0],base=16))[2:].zfill(bit_width) if '0x' in li[0] else bin(int(li[0]))[2:].zfill(bit_width) for li in vals ]
        if any([x[bit_width-bit-1]=='1' for x in legal]) and any([x[bit_width-bit-1]=='0' for x in legal]):
            return True
        else:
            return False

def getillegal(spec,dep_vals,num,node):
    end_vals = []
    legal = []
    try:
        spec = get_node(spec,node)
    except KeyError:
        return []
    bit_width = spec['msb']-spec['lsb']+1
    if 'warl' in spec['type']:
        warl = (warl_interpreter(spec['type']['warl']))
        deps = warl.dependencies()
        vals = warl.legal(eval(dep_vals))
        legal = [ bin(int(li[0],base=16))[2:].zfill(bit_width) if '0x' in li[0] else bin(int(li[0]))[2:].zfill(bit_width) for li in vals ]
    elif 'ro_constant' in spec['type']:
        legal = [bin(spec['type']['ro_constant'][0])[2:].zfill(bit_width)]
    num = int(num)
    if legal:
        while len(end_vals) < num:
            random.seed(datetime.now())
            flip_bits = random.sample(list(range(0,bit_width)),random.randint(0,bit_width-1))
            val = legal[random.randint(0,len(legal)-1)]
            flip = lambda x: '1' if x=='0' else '0'
            ill_val = ''.join([flip(val[i]) if i in flip_bits else val[i] for i in range(0,bit_width)])
            if ill_val not in legal:
                end_vals.append(ill_val)
    end_vals = [hex(int(x,base=2)<<spec['lsb']) for x in end_vals]
    return end_vals

def eval_macro(macro, spec):
    '''
        Function to evaluate the "def" statements in the database entry and return the macro string.

        :param macro: The "def" statement in the test which needs to be evaluated.

        :param spec: The specifications of the DUT.

        :type macro: str

        :type spec: dict

        :return: A 2 entry tuple. The first one being a boolean value indicating
            whether the macro was successfully defined and the second being the
            macro statement to be used while compilatio( in gcc format).

    '''
    args = (macro.replace("def ", "")).split("=")
    if ("True" in args[1]):
        return (True, [str(args[0]).strip() + "=" + str(args[1]).strip()])
    elif "getlegal" in args[1]:
        func_args = ((args[1].replace("getlegal(","")).replace(")","")).split(",")
        vals = getlegal(spec,func_args[0],func_args[1],func_args[2])
        if vals:
            return (True, [str(j).strip()+ "=" + str(k) for j,k in zip(args[0].split(","),vals)])
        else:
            return (False,[])
    elif "getillegal" in args[1]:
        func_args = ((args[1].replace("getillegal(","")).replace(")","")).split(",")
        vals = getillegal(spec,func_args[0],func_args[1],func_args[2])
        if vals:
            return (True, [str(j).strip()+ "=" + str(k) for j,k in zip(args[0].split(","),vals)])
        else:
            return (False,[])
    else:
        return (False,[])


def generate_test_pool(ispec, pspec):
    '''
        Funtion to select the tests which are applicable for the DUT and generate the macros
        necessary for each test.

        :param ispec: The isa specification for the DUT.

        :param pspec: The platform specification for the DUT.

        :type ispec: dict

        :type pspec: dict

        :return: A list of 3 entry tuples. Each entry in a list corresponds to a
            test which should be executed. In each tuple, the first entry is the
            path to the test relative to the riscof root, the second entry is the
            list of macros for the test and the third entry is the
            isa(adhering to RISCV specifications) required for the test.

    '''
    spec = {**ispec, **pspec}
    test_pool = []
    test_list = {}
    db = utils.load_yaml(constants.framework_db)
    for file in db:
        macros = []
        cov_labels = []
        for part in db[file]['parts']:
            include = True
            part_dict = db[file]['parts'][part]
            if 'coverage_labels' in part_dict:
                cov_labels.extend(part_dict['coverage_labels'])
            logger.debug("Checking conditions for {}-{}".format(file, part))
            for condition in part_dict['check']:
                include = include and eval_cond(condition, spec)
            if include:
                for macro in part_dict['define']:
                    temp = eval_macro(macro, spec)
                    if (temp[0]):
                        macros.extend(temp[1])
        if not macros == []:
            if '32' in db[file]['isa']:
                xlen = '32'
            elif '64' in db[file]['isa']:
                xlen = '64'
            elif '128' in db[file]['isa']:
                xlen = '128'
            macros.append("XLEN=" + xlen)
            test_pool.append(
                (file, db[file]['commit_id'], macros, db[file]['isa'],cov_labels))
    logger.info("Selecting Tests.")
    for entry in test_pool:
        # logger.info("Test file:" + entry[0])
        temp = {}
        if constants.suite in entry[0]:
            work_dir = os.path.join(constants.work_dir,entry[0].replace(constants.suite, '')[1:])
        else:
            work_dir = os.path.join(constants.work_dir,entry[0].replace("suite/", ''))
        Path(work_dir).mkdir(parents=True, exist_ok=True)
        temp['work_dir']=work_dir
        temp['macros']=entry[2]
        temp['isa']=entry[3]
        temp['coverage_labels'] = entry[4]
        if constants.suite in entry[0]:
            temp['test_path'] = entry[0]
        else:
            temp['test_path'] = os.path.join(constants.root,entry[0])
        test_list[entry[0]]=temp

    with open(os.path.join(constants.work_dir,"test_list.yaml"),"w") as tfile:
        yaml.dump(test_list,tfile)

    return (test_list, test_pool)


def run_tests(dut, base, ispec, pspec):
    '''
        Function to run the tests for the DUT.

        :param dut: The class instance for the DUT model.

        :param base: The class instance for the BASE model.

        :param ispec: The isa specifications of the DUT.

        :param pspec: The platform specifications of the DUT.

        :type ispec: dict

        :type pspec: dict

        :return: A list of dictionary objects containing the necessary information
            required to generate the report.
    '''
    test_list, test_pool = generate_test_pool(ispec, pspec)
    results = []
    logger.info("Running Tests on DUT.")
    dut.runTests(test_list)
    logger.info("Running Tests on Reference Model.")
    base.runTests(test_list)


    logger.info("Initiating signature checking.")
    for entry in test_pool:
        work_dir = test_list[entry[0]]['work_dir']
        res = os.path.join(test_list[entry[0]]['work_dir'],dut.name[:-1]+".signature")
        ref = os.path.join(test_list[entry[0]]['work_dir'],base.name[:-1]+".signature")
        result, diff = compare_signature(res, ref)
        res = {
            'name':
            entry[0],
            'res':
            result,
            'commit_id':
            entry[1],
            'log':
            'commit_id:' + entry[1] + "\nMACROS:\n" + "\n".join(entry[2]) +
            "" if result == "Passed" else diff,
            'path':
            work_dir,
            'repclass':
            result.lower()
        }
        results.append(res)

    logger.info('Following ' + str(len(test_pool)) + ' tests have been run :\n')
    logger.info('{0:<50s} : {1:<40s} : {2}'.format('TEST NAME', 'COMMIT ID',
                                                   'STATUS'))
    for res in results:
        if (res['res'] == 'Passed'):
            logger.info('{0:<50s} : {1:<40s} : {2}'.format(\
                res['name'], res['commit_id'], res['res']))
        else:
            logger.error('{0:<50s} : {1:<40s} : {2}'.format(\
                res['name'], res['commit_id'], res['res']))

    return results
