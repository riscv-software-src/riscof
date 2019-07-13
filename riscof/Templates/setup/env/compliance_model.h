#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H

//-----------------------------------------------------------------------
// Model specific Macros
//-----------------------------------------------------------------------

#define RVMODEL_DATA_SECTION                                                  \
//Define the data section required for debugging and io operations here.

//RV_COMPLIANCE_HALT
#define RVMODEL_HALT                                                          \
//Define the halt sequence for the implementation here.

#define RVMODEL_BOOT                                                          \
//Define the boot sequence for the implementation here.

//RV_COMPLIANCE_DATA_BEGIN
//Change the definition in the following macros if the implementation expects 
//different labels for identifying the signature section.
#define RVMODEL_DATA_BEGIN                                                    \
  RVMODEL_DATA_SECTION                                                        \
  .align 4; .global begin_signature; begin_signature:

//RV_COMPLIANCE_DATA_END
#define RVMODEL_DATA_END                                                      \
        .align 4; .global end_signature; end_signature:  


//Define the IO macros as required.
//RVTEST_IO_INIT
#define RVMODEL_IO_INIT                                                       \

//RVTEST_IO_WRITE_STR
#define RVMODEL_IO_WRITE_STR(_R, _STR)                                        \

//RVTEST_IO_CHECK
#define RVMODEL_IO_CHECK()                                                    \

//RVTEST_IO_ASSERT_GPR_EQ
#define RVMODEL_IO_ASSERT_GPR_EQ(_S, _R, _I)                                  \

//RVTEST_IO_ASSERT_SFPR_EQ
#define RVMODEL_IO_ASSERT_SFPR_EQ(_F, _R, _I)                                 \

//RVTEST_IO_ASSERT_DFPR_EQ
#define RVMODEL_IO_ASSERT_DFPR_EQ(_D, _R, _I)                                 \

#endif // _COMPLIANCE_MODEL_H
