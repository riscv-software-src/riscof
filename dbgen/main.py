import os
import git
import sys
import re
import oyaml as yaml

def dirwalk(dir):
    list = []
    for root, dirs, files in os.walk(os.getcwd()+"/"+dir):
        path = root[root.find(dir):]+"/"
        # print(path)
        for file in files:
            list.append(path+file)
    return list
def main():
    list = dirwalk("/suite/modified")
    repo = git.Repo("./")
    dbfile = "./framework/database.yaml"
    tree = repo.tree()
    db = {}
    cur_dir = os.getcwd()
    for file in list:
        print(file)
        commit = next(repo.iter_commits(paths="./"+file,max_count=1))
        with open(cur_dir+file,"r") as k:
            lines = k.read().splitlines()
            code_start=False
            part_start=False
            part_number = 0
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
                if "RVTEST_PART_START" in line:
                    if part_start == True:
                        print("{}:{}: Did not finish ({}) start".format(file, i, part_number))
                        sys.exit(0)
                    args = [(temp.strip()).replace("\"",'') for temp in (line.strip()).replace('RVTEST_PART_START','')[1:-1].split(',')]
                    while(line.endswith('\\')):
                        line = lines[i]
                        i+=1
                        line = line.strip()
                        if(line.startswith("#") or line.startswith("//")):
                            break
                        args[1]=args[1]+str((line.replace("\")",'')).replace("//",''))
                        # args.append([(temp.strip()).replace("\")",'') for temp in (line.strip())[:-1]].split)
                        if("\")" in line):
                            break
                    if(not args[0].isdigit() or int(args[0])<part_number):
                        print("{}:{}: Incorrect Naming of Test Case after ({})".format(file, i, part_number))
                        sys.exit(0)
                    part_number = int(args[0])
                    conditions = args[1].split(";")
                    check = []
                    define = []
                    for cond in conditions:
                        if(cond.startswith('check')):
                            check.append(cond)
                        elif(cond.startswith('def')):
                            define.append(cond)
                    part_dict[part_number] = {'check':check,'define':define}
                if "RVTEST_PART_END" in line:
                    args = [temp.strip() for temp in (line.strip()).replace('RVTEST_PART_END','')[1:-1].split(',')]
                    if int(args[0]) != part_number:
                        print("{}:{}: Wrong Test Case Numbering in ({})".format(file, i, part_number))
                        sys.exit(0)
                    part_start = False
        db[file] = {'commit_id':str(commit),'parts':part_dict}
    with open(dbfile,"w") as wrfile:
        yaml.dump(db, wrfile, default_flow_style=False, allow_unicode=True)
        # print(file+" "+str(commit))



if __name__=='__main__':
    main()