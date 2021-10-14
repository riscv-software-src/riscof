# See LICENSE.incore for details
import os
import git
import sys
import re
import pytz
from datetime import datetime
from riscof.utils import yaml
import riscof.utils as utils
import collections
import logging
from git import InvalidGitRepositoryError
import riscof.constants as constants
import riscof.arch_test as arch_test

logger = logging.getLogger(__name__)

class DbgenError(Exception):
    pass

isa_regex = re.compile('''RVTEST_ISA\(\"(?P<isa>.*)\"\)''')
case_regex = re.compile('''RVTEST_CASE\((?P<id>.*),\"(?P<cond>.*)\",(?P<cov_label>.*)\)''')

def dirwalk(dir,ignore_dirs=[]):
    '''
        Recursively searches a directory and returns a list of
        relative paths(from the directory) of the files which end with ".S"(excluding any folder named wip).

        :params: dir - The directory in which the files have to be searched for.

        :return: a list of all .S file paths relative to the riscof home.
    '''
    list = []
    for root, dirs, files in os.walk(dir):
        if not any([i in root for i in ignore_dirs]):
            path = root[root.find(dir):] + "/"
            for file in files:
                if file.endswith(".S"):
                    list.append(os.path.join(path, file))
    return list


def orderdict(foo):
    '''
        Creates and returns a sorted dictionary from a given dictionary.
        :params foo: The dictionary which needs to be sorted.

        :type foo: dict

        :return: A dictionary with alphabetically sorted(based on keys) entries.

    '''
    ret = collections.OrderedDict()
    for key in sorted(foo.keys()):
        ret[key] = foo[key]
    return ret


def createdict(file):
    '''
        Parse the file and create the dictionary node for it.

        :param file: The relative path of the test from riscof home.

        :type file: str

        :return: A dictionary containing all the necesary nodes for the file.

        :raise DbgenError: Raised if the test file doesnt adhere to the rules.
    '''
    with open(file, "r") as k:
        lines = k.read().splitlines()
        code_start = False
        part_start = False
        isa = None
        part_number = 'START'
        i = 0
        part_dict = {}
        line_prev = ''
        while i < len(lines):
            line = lines[i]
            i += 1
            line = line.strip()
            if line == "":
                continue
            if (line.startswith("#") or line.startswith("//")):
                continue
            re_search = isa_regex.search(line)
            if re_search is not None:
                isa = [x.strip() for x in (re_search.group('isa')).split(",")]
            if "RVTEST_CASE(" in line:
                temp = ''
                lno = i
                if line.endswith('\\'):
                    temp += (line.strip()).replace("\\", '')
                    while (line.endswith('\\')):
                        line = lines[i]
                        i += 1
                        temp += (line.strip()).replace("\\", '')
                else:
                    temp = line.strip()
                re_search = case_regex.search(temp)
                if re_search is not None:
                    part_number = re_search.group("id")
                    conditions = (re_search.group("cond").replace("//",'')).split(";")
                    labels = [l.strip() for l in (re_search.group("cov_label")).split(",")]

                    if (part_number in part_dict.keys()):
                        logger.warning("{}:{}: Incorrect Naming of Test Case after ({})".
                              format(file, lno, part_number))
                        logger.warning("Skipping file {}. This test will not be included in the\
 database.".format(file))
                        raise DbgenError

                    check = []
                    define = []
                    for cond in conditions:
                        cond = cond.strip()
                        if (cond.startswith('check')):
                            check.append(cond)
                        elif (cond.startswith('def')):
                            define.append(cond)
                    part_dict[part_number] = {'check': check, 'define': define,'coverage_labels':labels}
                else:
                    logger.warning("{}:{}: Incorrect Case String ({})".format(file, lno, part_number))
                    logger.warning("Skipping file {}. This test will not be included in the\
 database.".format(file))
                    raise DbgenError
    if (isa is None):
        logger.warning("{}:ISA not specified.".format( file))
        raise DbgenError
    if len(part_dict.keys()) == 0:
        logger.warning("{}: Atleast one part must exist in the test.".format(file))
        raise DbgenError
    return {'isa': [str(x) for x in isa], 'parts': orderdict(part_dict)}

def check_commit(repo, fpath, old_commit):
    commit = next(
        repo.iter_commits(paths=fpath, max_count=1))
    if (str(commit) != old_commit):
        update = True
    return str(commit), update

def generate():
    flist = dirwalk(constants.suite)

    _ , is_repo = arch_test.get_version(constants.suite)

    dbfile = constants.framework_db
    logger.debug("Using "+dbfile)
    if is_repo:
        repo = git.Repo(constants.suite,search_parent_directories=True)
        tree = repo.tree()
    try:
        db = utils.load_yaml(dbfile)
        delkeys = []
        for key in db.keys():
            if key not in list:
                delkeys.append(key)
        for key in delkeys:
            del db[key]
    except FileNotFoundError:
        db = {}
    existing = db.keys()
    new = [x for x in flist if x not in existing]
    deleted_files = [x for x in existing if x not in flist]
    for entry in deleted_files:
        del db[entry]
    if is_repo:
        for fpath in existing:
            commit_id, update = check_commit(repo,fpath,db[fpath]['commit_id'])
            if(update):
                try:
                    temp = createdict(fpath)
                except DbgenError:
                    del db[fpath]
                    continue
                db[fpath] = {'commit_id': commit_id, **temp}
        for fpath in new:
            commit_id, update = check_commit(repo,fpath,'-')
            try:
                temp = createdict(fpath)
            except DbgenError:
                continue
            db[fpath] = {'commit_id': commit_id, **temp}
    else:
        for fpath in new:
            try:
                temp = createdict(fpath)
            except:
                continue
            db[fpath] = {'commit_id': '-', **temp}
    with open(dbfile, "w") as wrfile:
        wrfile.write('# database generated on ' + (datetime.now(pytz.timezone('GMT'))).strftime("%Y-%m-%d %H:%M GMT")+'\n')
        yaml.dump(orderdict(db),
                  wrfile)
