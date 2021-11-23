import logging
import re
import sys
import os
from pathlib import Path
import difflib
import ast
import pytz
import random
from datetime import datetime
from copy import deepcopy

from riscof.utils import yaml
import riscof.utils as utils
import riscof.constants as constants
from riscv_config.warl import warl_interpreter

logger = logging.getLogger(__name__)

class TestSelectError(Exception):
    "Raised on an error while selecting Tests."
    pass

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
        raise SystemExit(1)
    file1_lines = open(file1, "r").readlines()
    file2_lines = open(file2, "r").readlines()
    res = ("".join(
        difflib.unified_diff(file1_lines,file2_lines, file1, file2))).strip()
    if res == "":
        if len(file1_lines)==0:
            return 'Failed', '---- \nBoth FIles empty\n'
        else:
            status = 'Passed'
    else:
        status = 'Failed'

        error_report = '\nFile1 Path:{0}\nFile2 Path:{1}\nMatch  Line#    File1    File2\n'.format(
                            file1,file2)
        fmt = "{0:5s} {1:6d} {2:8s} {3:8s}\n"
        prev = ''
        include = False
        for lnum,lines in enumerate(zip(file1_lines,file2_lines)):
            if lines[0] != lines[1]:
                include = True
                if not include:
                    error_report += prev
                rline = fmt.format("*",lnum,lines[0].strip(),lines[1].strip())
                error_report += rline
                prev = rline
            elif include:
                rline = fmt.format("",lnum,lines[0].strip(),lines[1].strip())
                error_report += rline
                include = False
                prev = rline
        res = error_report
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

def isa_set(string):
    str_match = re.findall(r'([^\d]*?)(?!_)*(Z.*?)*(_|$)',string,re.M)
    extension_list= []
    for match in str_match:
        stdisa, z, ignore = match
        if stdisa != '':
            for e in stdisa:
                extension_list.append(e)
        if z != '':
            extension_list.append(z)
    return set(extension_list)

def canonicalise(isa):
    all_ext = ["M","A","F","D","Q","L","C","B","J","K","T","P","V","N","S","H","U","Zicsr",
            "Zifencei","Zihintpause","Zmmul","Zam","Zbc","Zbb","Zbp","Zbm","Zbe","Zbf","Zkne",
            "Zknd","Zknh","Zkse","Zksh","Zkg","Zkb","Zkr","Zks","Zkn","Ztso"]
    canonical_string = ""
    switch = False
    for ext in all_ext:
        if ext in isa:
            if switch:
                canonical_string += "_"
            elif ext.startswith("Z"):
                switch=True
            canonical_string += ext
            if ext.startswith("Z"):
                switch=True
    return canonical_string


def prod_isa(dut_isa, test_isa):
    '''
        Function to generate the isa a test has to be compiled with. The various possible ISAs a
        test can be compiled with is compared with the ISA defined in the DUT specification.

        :param dut_isa: The ISA field in the DUT specification.

        :param test_isa: A list of ISA strings from the test.

        :type dut_isa: str

        :type test_isa: list(str)

        :return: The maximal set of all the applicable ISA strings from the test in canonical form.

        :raises: TestSelectError

    '''
    dut_exts = isa_set(re.sub("RV(64|128|32)(I|E)","",dut_isa))
    isa = set([])
    last_prefix = ''
    atleast_1 = False
    for entry in test_isa:
        match = re.findall("(?P<prefix>RV(64|128|32)(I|E))",entry)
        prefix = match[0][0]
        exts = isa_set(re.sub("RV(64|128|32)(I|E)","",entry))
        overlap = dut_exts & exts
        if overlap == exts:
            atleast_1 = True
            isa = isa | overlap
            if last_prefix:
                if last_prefix != prefix:
                    raise TestSelectError("Incompatiple prefix for valid ISA strings in test.")
            last_prefix = prefix
    if not atleast_1:
        raise TestSelectError("Test Selected without the relevant extensions being available on DUT.")
    return prefix+canonicalise(isa)

def generate_test_pool(ispec, pspec, workdir, dbfile = None):
    '''
        Funtion to select the tests which are applicable for the DUT and generate the macros
        necessary for each test.

        :param ispec: The isa specification for the DUT.

        :param pspec: The platform specification for the DUT.

        :type ispec: dict

        :type pspec: dict

        :return: A dictionary which contains all the necessary information for the selected tests.
        Refer to Test List Format for further information.

    '''
    spec = {**ispec, **pspec}
    test_pool = []
    test_list = {}
    if dbfile is not None:
        db = utils.load_yaml(dbfile)
    else:
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
            try:
                isa = prod_isa(ispec['ISA'],db[file]['isa'])
            except TestSelectError as e:
                logger.error("Error in test: "+str(file)+"\n"+str(e))
                continue
            if '32' in isa:
                xlen = '32'
            elif '64' in isa:
                xlen = '64'
            elif '128' in isa:
                xlen = '128'
            macros.append("XLEN=" + xlen)
            if re.match(r"^[^(Z,z)]+D.*$",isa):
                macros.append("FLEN=64")
            elif re.match(r"^[^(Z,z)]+F.*$",isa):
                macros.append("FLEN=32")
            test_pool.append(
                (file, db[file]['commit_id'], macros,isa,cov_labels))
    logger.info("Selecting Tests.")
    for entry in test_pool:
        # logger.info("Test file:" + entry[0])
        temp = {}
        if constants.suite in entry[0]:
            work_dir = os.path.join(workdir,entry[0].replace(constants.suite, '')[1:])
        else:
            work_dir = os.path.join(workdir,entry[0].replace("suite/", ''))
        Path(work_dir).mkdir(parents=True, exist_ok=True)
        temp['commit_id']=entry[1]
        temp['work_dir']=work_dir
        temp['macros']=entry[2]
        temp['isa']=entry[3]
        temp['coverage_labels'] = entry[4]
        if constants.suite in entry[0]:
            temp['test_path'] = entry[0]
        else:
            temp['test_path'] = os.path.join(constants.root,entry[0])
        test_list[entry[0]]=temp
    if (len(test_list) == 0):
        logger.error('No Tests Selected')
        raise SystemExit(1)

    with open(os.path.join(workdir,"test_list.yaml"),"w") as tfile:
        tfile.write('# testlist generated on ' + (datetime.now(pytz.timezone('GMT'))).strftime("%Y-%m-%d %H:%M GMT")+'\n')
        yaml.dump(test_list,tfile)

    return (test_list, test_pool)


def run_tests(dut, base, ispec, pspec, work_dir, cntr_args):
    '''
        Function to run the tests for the DUT.

        :param dut: The class instance for the DUT model.

        :param base: The class instance for the BASE model.

        :param ispec: The isa specifications of the DUT.

        :param pspec: The platform specifications of the DUT.

        :param cntr_args: dbfile, testfile, no_ref_run, no_dut_run

        :type ispec: dict

        :type pspec: dict

        :return: A list of dictionary objects containing the necessary information
            required to generate the report.
    '''
    if cntr_args[1] is not None:
        test_list = utils.load_yaml(cntr_args[1])
    else:
        test_list, test_pool = generate_test_pool(ispec, pspec, work_dir, cntr_args[0])
    dut_test_list = {}
    base_test_list = {}
    for entry in test_list:
        node = test_list[entry]
        dut_test_list[entry] = deepcopy(node)
        base_test_list[entry] = deepcopy(node)
        dut_test_list[entry]['work_dir'] = os.path.join(node['work_dir'],'dut')
        os.mkdir(dut_test_list[entry]['work_dir'])
        base_test_list[entry]['work_dir'] = os.path.join(node['work_dir'],'ref')
        os.mkdir(base_test_list[entry]['work_dir'])
    results = []
    if cntr_args[2]:
        logger.info("Running Tests on DUT.")
        dut.runTests(dut_test_list)
        logger.info("Tests run on DUT done.")
        raise SystemExit(0)
    elif cntr_args[3]:
        logger.info("Running Tests on Reference Model.")
        base.runTests(base_test_list)
        logger.info("Tests run on Reference done.")
        raise SystemExit(0)
    else:
        logger.info("Running Tests on DUT.")
        dut.runTests(dut_test_list)
        logger.info("Running Tests on Reference Model.")
        base.runTests(base_test_list)

    logger.info("Initiating signature checking.")
    for file in test_list:
        testentry = test_list[file]
        work_dir = testentry['work_dir']
        res = os.path.join(dut_test_list[file]['work_dir'],dut.name[:-1]+".signature")
        ref = os.path.join(base_test_list[file]['work_dir'],base.name[:-1]+".signature")
        result, diff = compare_signature(res, ref)
        res = {
            'name':
            file,
            'res':
            result,
            'commit_id':
            testentry['commit_id'],
            'log':
            'commit_id:' + testentry['commit_id'] + "\nMACROS:\n" + "\n".join(testentry['macros']) +
            ("" if result == "Passed" else diff),
            'path':
            work_dir,
            'repclass':
            result.lower()
        }
        results.append(res)

    logger.info('Following ' + str(len(test_list)) + ' tests have been run :\n')
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
