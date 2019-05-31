import os
import git

def dirwalk(dir):
    list = []
    for root, dirs, files in os.walk(os.getcwd()+"/"+dir):
        path = root[root.find(dir):]+"/"
        # print(path)
        for file in files:
            list.append(path+file)
    return list
def main():
    list = dirwalk("/suite")
    repo = git.Repo("./")
    tree = repo.tree()
    db = {}
    cur_dir = os.getcwd()
    for file in list:
        commit = next(repo.iter_commits(paths="./"+file,max_count=1))
        with open(cur_dir+file,"r") as k:
            for line in k:
                print(line)
            
        db[file]={'commit_id':str(commit)}
        print(file+" "+str(commit))



if __name__=='__main__':
    main()