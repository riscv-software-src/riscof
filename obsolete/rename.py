import os
import riscof.constants as constants

dir = constants.suite[:-1]

for root, dirs, files in os.walk(os.path.join(constants.root, dir)):
    if "/wip" in root:
        path = root[root.find(dir):] + "/"
        for file in files:
            if file.endswith(".S") and file.startswith("C"):
                fpath = os.getcwd() + "/riscof/" + os.path.join(path, file)
                print(fpath)
                with open(fpath, "r") as filep:
                    lines = filep.readlines()
                with open(fpath, "w") as filep:
                    for content in lines:
                        content = content.replace(
                            '''#include "test_macros.h"''', "")
                        content = content.replace('''RV_COMPLIANCE_RV32M''', "")
                        content = content.replace(
                            '''#include "compliance_io.h"''',
                            '''#include "compliance_model.h"''')
                        content = content.replace(
                            '''RV_COMPLIANCE_CODE_BEGIN''',
                            '''RVTEST_CODE_BEGIN''')
                        content = content.replace('''RV_COMPLIANCE_CODE_END''',
                                                  '''RVTEST_CODE_END''')
                        content = content.replace('''RV_COMPLIANCE_HALT''',
                                                  '''RVMODEL_HALT''')
                        content = content.replace(
                            '''RV_COMPLIANCE_DATA_BEGIN''',
                            '''RVMODEL_DATA_BEGIN''')
                        content = content.replace('''RV_COMPLIANCE_DATA_END''',
                                                  '''RVMODEL_DATA_END''')
                        content = content.replace('''RVTEST_IO_INIT''',
                                                  '''RVMODEL_IO_INIT''')
                        content = content.replace('''RVTEST_IO_WRITE_STR''',
                                                  '''RVMODEL_IO_WRITE_STR''')
                        content = content.replace('''RVTEST_IO_CHECK''',
                                                  '''RVMODEL_IO_CHECK''')
                        if "RVTEST_IO_ASSERT_GPR_EQ" in content:
                            continue
                        content = content.replace(
                            '''RVTEST_IO_ASSERT_SFPR_EQ''',
                            '''RVMODEL_IO_ASSERT_SFPR_EQ''')
                        content = content.replace(
                            '''RVTEST_IO_ASSERT_DFPR_EQ''',
                            '''RVMODEL_IO_ASSERT_DFPR_EQ''')
                        if "la" in content and "res" in content:
                            content = ((content.replace(
                                "la", "RVTEST_SIGBASE(")).replace(
                                    ";", "")).rstrip() + ")\n"
                        if "TEST_CR_OP" in content:
                            args = (((content.replace(
                                "TEST_CR_OP(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CR_OP")]+"li "+args[2]+","+args[4]+";\n"+ \
                                "li "+args[1]+","+args[5]+";\n"+args[0]+" "+args[1]+","+args[2]+";\n"+ \
                                "RVTEST_SIGUPD("+args[6]+","+args[1]+","+args[3]+")\n"
                        if "TEST_CI_OP" in content:
                            args = (((content.replace(
                                "TEST_CI_OP(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CI_OP")]+\
                                "li "+args[1]+","+args[3]+";\n"+args[0]+" "+args[1]+","+args[4]+";\n"+ \
                                "RVTEST_SIGUPD("+args[5]+","+args[1]+","+args[2]+")\n"
                        if "TEST_CI_OP_NOREG" in content:
                            args = (((content.replace(
                                "TEST_CI_OP_NOREG(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CI_OP_NOREG")]+\
                                args[0]+" "+args[2]+";\n"+ \
                                "RVTEST_SIGUPD("+args[3]+",x0,"+args[1]+")\n"
                        if "TEST_CADDI16SP" in content:
                            args = (((content.replace(
                                "TEST_CADDI16SP(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CADDI16SP")]+\
                                "c.addi16sp x2,"+args[1]+";\n"+ \
                                "RVTEST_SIGUPD("+args[2]+",x2,"+args[0]+")\n"
                        if "TEST_CADDI4SPN" in content:
                            args = (((content.replace(
                                "TEST_CADDI4SPN(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CADDI4SPN")]+\
                                "c.addi14spn "+args[0]+",x2,"+args[2]+";\n"+ \
                                "RVTEST_SIGUPD("+args[3]+","+args[0]+","+args[1]+")\n"
                        if "TEST_CJL" in content:
                            args = (((content.replace("TEST_CJL(", "")).replace(
                                ")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CJL")]+\
                                "li x10,"+args[2]+";\n"+"la "+args[1]+",1f;\n"+\
                                args[0]+" "+args[1]+";\n"+"li x10,0x123ab;\n"+\
                                "1:\nRVTEST_SIGUPD("+args[3]+",x10,"+args[2]+")\n"
                        if "TEST_CJ" in content:
                            args = (((content.replace("TEST_CJ(", "")).replace(
                                ")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CJ")]+\
                                "li "+args[1]+","+args[2]+";\n"+\
                                args[0]+" 1f;\nli "+args[1]+",0x123ab;\n"+\
                                "1:\nRVTEST_SIGUPD("+args[3]+","+args[1]+","+args[2]+")\n"
                        if "TEST_CLWSP" in content:
                            args = (((content.replace(
                                "TEST_CLWSP(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CLWSP")]+\
                                "la x2,test_data;\nc.lwsp "+\
                                args[0]+","+args[1]+"(x2);\nRVTEST_SIGUPD("+args[2]+","+args[0]+","+"0x00)\n"
                        if "TEST_CL" in content:
                            args = (((content.replace("TEST_CL(", "")).replace(
                                ")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CL")]+\
                                "la "+args[1]+",test_data;\n"+\
                                args[0]+" "+args[1]+","+args[2]+"("+args[1]+");\nRVTEST_SIGUPD("+args[3]+","+args[1]+","+args[2]+")\n"
                        if "TEST_CSWSP" in content:
                            args = (((content.replace(
                                "TEST_CSWSP(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CSWSP")]+\
                                "la x2,"+args[0]+";\nli "+args[1]+","+args[2]+";\nc.swsp "+args[1]+","+args[3]+"(x2);\nlw "+\
                                args[1]+","+args[3]+"(x2);\nRVTEST_SIGUPD("+args[4]+","+args[1]+","+args[2]+")\n"
                        if "TEST_CSW" in content:
                            args = (((content.replace("TEST_CSW(", "")).replace(
                                ")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CSW")]+\
                                "li "+args[2]+","+args[4]+";\nla "+\
                                args[3]+","+args[0]+";\n"+args[1]+" "+args[2]+","+args[5]+"("+args[3]+");\nlw "+\
                                args[2]+","+args[5]+"("+args[3]+");\nRVTEST_SIGUPD("+args[6]+","+args[2]+","+args[4]+")\n"
                        if "TEST_CBEQZ" in content:
                            args = (((content.replace(
                                "TEST_CBEQZ(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CBEQZ")]+\
                                "li "+args[0]+","+args[1]+";\nc.sub "+args[0]+","+args[0]+";\nc.beqz "+args[0]+",3f;\nli "+\
                                args[0]+",0x123ab;\n3:\nRVTEST_SIGUPD("+args[2]+","+args[0]+",0x00);\n"
                        if "TEST_CBNEZ" in content:
                            args = (((content.replace(
                                "TEST_CBNEZ(",
                                "")).replace(")", "")).strip()).split(",")
                            content = content[:content.find("TEST_CBNEZ")]+\
                                "li "+args[0]+","+args[1]+";\nc.beqz "+args[0]+",4f;\nli "+\
                                args[0]+",0x00;\n3:\nRVTEST_SIGUPD("+args[2]+","+args[0]+","+args[1]+");\n"
                        filep.write(content)
