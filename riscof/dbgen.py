import os
import git
import sys
import re
import oyaml as yaml
import collections

import riscof.constants as constants

def dirwalk(dir):
    list = []
    for root, dirs, files in os.walk(os.getcwd()+"/"+dir):
        path = root[root.find(dir):]+"/"
        for file in files:
            list.append(path+file)
    return list

def orderdict(dict):
    ret = collections.OrderedDict()
    for key in sorted(dict.keys()):
        ret[key] = dict[key]
    return ret

def createdict(file):
    with open(file,"r") as k:
        lines = k.read().splitlines()
        code_start=False
        part_start=False
        isa = None
        part_number = ''
        i=0
        part_dict={}
        while i<len(lines):
            line = lines[i]
            i+=1
            line = line.strip()
            if line == "":
                continue
            if(line.startswith("#") or line.startswith("//")):
                continue
            if "RVTEST_ISA" in line:
                isa = (((line.strip()).replace('RVTEST_ISA(\"',"")).replace("\")","")).strip()
            if "RVTEST_CASE_START" in line:
                if part_start == True:
                    print("{}:{}: Did not finish ({}) start".format(file, i, part_number))
                    sys.exit(0)
                args = [(temp.strip()).replace("\"",'') for temp in (line.strip()).replace('RVTEST_CASE_START','')[1:-1].split(',')]
                while(line.endswith('\\')):
                    line = lines[i]
                    i+=1
                    line = (line.strip()).replace("//",'')
                    args[1]=args[1]+str((line.replace("\")",'')).replace("//",''))
                    # args.append([(temp.strip()).replace("\")",'') for temp in (line.strip())[:-1]].split)
                    if("\")" in line):
                        break
                if(args[0] in part_dict.keys()):
                    print("{}:{}: Incorrect Naming of Test Case after ({})".format(file, i, part_number))
                    sys.exit(0)
                part_number = args[0]
                conditions = (args[1].replace("//",'')).split(";")
                check = []
                define = []
                for cond in conditions:
                    cond = cond.strip()
                    if(cond.startswith('check')):
                        check.append(cond)
                    elif(cond.startswith('def')):
                        define.append(cond)
                part_dict[part_number] = {'check':check,'define':define}
            if "RVTEST_CASE_END" in line:
                args = [(temp.strip()).replace("\"",'') for temp in (line.strip()).replace('RVTEST_CASE_END','')[1:-1].split(',')]
                if args[0] != part_number:
                    print("{}:{}: Wrong Test Case Numbering in ({})".format(file, i, part_number))
                    sys.exit(0)
                part_start = False
    if(isa is None):
        print("{}:ISA not specified.",file)
        sys.exit(0)
    if len(part_dict.keys()) == 0:
        print("{}: Atleast one part must exist in the test.",file)
        sys.exit(0) 
    return {'isa':str(isa),'parts':orderdict(part_dict)}
def generate():
    list = dirwalk(constants.suite[:-1])
    repo = git.Repo("./")
    dbfile = constants.framework_db
    tree = repo.tree()
    try:
        with open(dbfile,"r") as temp:
            db = yaml.safe_load(temp)
            for key in db.keys():
                if key not in list:
                    del db[key]
    except FileNotFoundError:
        db={}
    cur_dir = os.getcwd()
    existing = db.keys()
    new = [x for x in list if x not in existing]
    for file in existing:
        commit = next(repo.iter_commits(paths="./"+file,max_count=1))
        if(str(commit) != db[file]['commit_id']):
            temp = createdict(cur_dir+file)
            db[file] = {'commit_id':str(commit),**temp}
    for file in new:
        commit = next(repo.iter_commits(paths="./"+file,max_count=1))
        temp = createdict(cur_dir+file)
        db[file] = {'commit_id':str(commit),**temp}
    with open(dbfile,"w") as wrfile:
        yaml.dump(orderdict(db), wrfile, default_flow_style=False, allow_unicode=True)



if __name__=='__main__':
    generate()