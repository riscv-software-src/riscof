import logging
import common.utils as utils
from framework.test_list import *
import filecmp

logger = logging.getLogger(__name__)

def compare_signature(file1,file2):
    if( filecmp.cmp(file1,file2) ):
        status='Passed'
    else:
        status='Failed'
    return status

# test_pool = [['I-ADD-01' ,'rv32i', 'I in ISA'],
#     ['I-ADDI-01' ,'rv32i', 'I in ISA'],
#     ['I-AND-01' ,'rv32i', 'I in ISA'],
#     ['I-ANDI-01' ,'rv32i', 'I in ISA'],
#     ['I-AUIPC-01' ,'rv32i', 'I in ISA'],
#     ['I-BEQ-01' ,'rv32i', 'I in ISA'],
#     ['I-BNE-01' ,'rv32i', 'I in ISA'],
#     ['I-BGE-01' ,'rv32i', 'I in ISA'],
#     ['I-BGEU-01' ,'rv32i', 'I in ISA'],
#     ['I-BLT-01' ,'rv32i', 'I in ISA'],
#     ['I-BLTU-01' ,'rv32i', 'I in ISA'],
#     ['I-CSRRW-01' ,'rv32i', 'I in ISA'],
#     ['I-CSRRC-01' ,'rv32i', 'I in ISA'],
#     ['I-CSRRWI-01' ,'rv32i', 'I in ISA'],
#     ['I-CSRRCI-01' ,'rv32i', 'I in ISA'],
#     ['I-CSRRS-01' ,'rv32i', 'I in ISA'],
#     ['I-CSRRSI-01' ,'rv32i', 'I in ISA'],
#     ['I-DELAY_SLOTS-01' ,'rv32i', 'I in ISA'],
#     ['I-ENDIANESS-01' ,'rv32i', 'I in ISA'],
#     ['I-FENCE.I-01' ,'rv32i', 'I in ISA'],
#     ['I-IO' ,'rv32i', 'I in ISA'],
#     ['I-JAL-01' ,'rv32i', 'I in ISA'],
#     ['I-JALR-01' ,'rv32i', 'I in ISA'],
#     ['I-LB-01' ,'rv32i', 'I in ISA'],
#     ['I-LBU-01' ,'rv32i', 'I in ISA'],
#     ['I-LH-01' ,'rv32i', 'I in ISA'],
#     ['I-LHU-01' ,'rv32i', 'I in ISA'],
#     ['I-LW-01' ,'rv32i', 'I in ISA'],
#     ['I-LUI-01' ,'rv32i', 'I in ISA'],
#     ['I-NOP-01' ,'rv32i', 'I in ISA'],
#     ['I-OR-01' ,'rv32i', 'I in ISA'],
#     ['I-ORI-01' ,'rv32i', 'I in ISA'],
#     ['I-RF_size-01' ,'rv32i', 'I in ISA'],
#     ['I-RF_width-01' ,'rv32i', 'I in ISA'],
#     ['I-RF_x0-01' ,'rv32i', 'I in ISA'],
#     ['I-SB-01' ,'rv32i', 'I in ISA'],
#     ['I-SH-01' ,'rv32i', 'I in ISA'],
#     ['I-SLL-01' ,'rv32i', 'I in ISA'],
#     ['I-SLLI-01' ,'rv32i', 'I in ISA'],
#     ['I-SLT-01' ,'rv32i', 'I in ISA'],
#     ['I-SLTI-01' ,'rv32i', 'I in ISA'],
#     ['I-SLTIU-01' ,'rv32i', 'I in ISA'],
#     ['I-SLTU-01' ,'rv32i', 'I in ISA'],
#     ['I-SRA-01' ,'rv32i', 'I in ISA'],
#     ['I-SRAI-01' ,'rv32i', 'I in ISA'],
#     ['I-SRL-01' ,'rv32i', 'I in ISA'],
#     ['I-SRLI-01' ,'rv32i', 'I in ISA'],
#     ['I-SW-01' ,'rv32i', 'I in ISA'],
#     ['I-SUB-01' ,'rv32i', 'I in ISA'],
#     ['I-XOR-01' ,'rv32i', 'I in ISA'],
#     ['I-XORI-01' ,'rv32i', 'I in ISA']]

def collect_unprivilege(isa):
    global user_target
    dut_test_pool = []
    for test in unprivilege_test_pool:
        if(len(test)<2):
            logger.error('Test list should be atleast 2 entries: Test name and\
 march')
            sys.exit(0)
        if(len(test)==2):
            dut_test_pool.append(test)
        else:
            criteria = test[2:]
            select = True
            for c in criteria:
                if not eval(c.lower()):
                    select=False
            if select:
                dut_test_pool.append(test)
            #     if 'in' in c:
            #         x = c.split();
            #         if (len(x)!=3):
            #             logger.error('Wrong Criteria Syntax for test: '+\
            #                         str(test[0]))
            #             sys.exit(0)

            #         if x[0].isdigit():
            #             if int(x[0]) not in foo[x[2]]:
            #                 select=False
            #         elif x[0] not in foo[x[2]]:
            #             select=False
            # if select:
            #     dut_test_pool.append([test[0],test[1]])
    return dut_test_pool

def execute(dut,base,ispec,pspec):
    test_pool = collect_unprivilege(ispec['ISA'].lower())
    log = []
    for entry in test_pool:
        logger.info("Test file:"+entry[0])
        logger.info("Initiating Compilation.")
        dut.compile(entry[0]," -DTEST_PART_1=True")
        logger.info("Running DUT simulation.")
        res = dut.simulate(entry[0])
        logger.info("Running Base Model simulation")
        ref = base.simulate(entry[0])
        logger.info("Initiating check.")
        log.append([entry[0],compare_signature(res,ref)])
    
    logger.info('Following '+str(len(test_pool))+' Unprivileged \
tests have been run :\n')
    logger.info('{0:<25s} : {1}\n'.format('TEST NAME','STATUS'))
    # print(log)
    for x in range(0,len(test_pool)):
        if(log[x][1]=='Passed'):
            logger.info('{0:<25s}: {1}'.format(\
                log[x][0], log[x][1]))
        else:
            logger.error('{0:<25s}: {1}'.format(\
                log[x][0], log[x][1]))

