import os
import riscof.constants as constants

dir = constants.suite[:-1]

for root, dirs, files in os.walk(os.path.join(constants.root, dir)):
    if "/wip" not in root:
        path = root[root.find(dir):] + "/"
        for file in files:
            if file.endswith(".S"):
                fpath = os.getcwd() + "/riscof/" + os.path.join(path, file)
                print(fpath)
                with open(fpath, "r") as filep:
                    content = filep.read()
                content = content.replace('''#include "test_macros.h"''', "")
                content = content.replace('''RV_COMPLIANCE_RV32M''', "")
                content = content.replace('''#include "compliance_io.h"''',
                                          '''#include "compliance_model.h"''')
                content = content.replace('''RV_COMPLIANCE_CODE_BEGIN''',
                                          '''RVTEST_CODE_BEGIN''')
                content = content.replace('''RV_COMPLIANCE_CODE_END''',
                                          '''RVTEST_CODE_END''')
                content = content.replace('''RV_COMPLIANCE_HALT''',
                                          '''RVMODEL_HALT''')
                content = content.replace('''RV_COMPLIANCE_DATA_BEGIN''',
                                          '''RVMODEL_DATA_BEGIN''')
                content = content.replace('''RV_COMPLIANCE_DATA_END''',
                                          '''RVMODEL_DATA_END''')
                content = content.replace('''RVTEST_IO_INIT''',
                                          '''RVMODEL_IO_INIT''')
                content = content.replace('''RVTEST_IO_WRITE_STR''',
                                          '''RVMODEL_IO_WRITE_STR''')
                content = content.replace('''RVTEST_IO_CHECK''',
                                          '''RVMODEL_IO_CHECK''')
                content = content.replace('''RVTEST_IO_ASSERT_GPR_EQ''',
                                          '''RVMODEL_IO_ASSERT_GPR_EQ''')
                content = content.replace('''RVTEST_IO_ASSERT_SFPR_EQ''',
                                          '''RVMODEL_IO_ASSERT_SFPR_EQ''')
                content = content.replace('''RVTEST_IO_ASSERT_DFPR_EQ''',
                                          '''RVMODEL_IO_ASSERT_DFPR_EQ''')
                with open(fpath, "w") as filep:
                    filep.write(content)
