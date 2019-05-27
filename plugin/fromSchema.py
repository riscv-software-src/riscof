class fromSchema():
    def __init__(self, schema):
        self.env = schema['USER_ENV_DIR']
        self.linker = schema['USER_LINKER']
        self.target = schema['USER_TARGET']
        self.exe = schema['USER_EXECUTABLE']
        self.abi = schema['USER_ABI']
        self.signature = schema['USER_SIGN']
        self.pref = schema['RISCV_PREFIX']
        self.post = schema['USER_POST_SIM']
        self.pre = schema['USER_PRE_SIM']
    
    def presim(self,file):
        print(self.pre)
    def postsim(self,file):
        print(self.post)
    def execute(self,file):
        print(self.exe)