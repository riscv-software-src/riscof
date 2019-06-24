import os
from yapf.yapflib.yapf_api import FormatFile

for rootdir,folders,files in os.walk("riscof"):
    for file in files:
        if file.endswith(".py"):
            FormatFile(rootdir+"/"+file,style_config="google",in_place=True)