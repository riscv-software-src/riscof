import os

root = os.path.abspath(os.path.dirname(__file__))

suite = os.path.join(root,"suite/")
#cgf_dir = os.path.join(root,"coverage/")
#
#cgf_file = []
#cgf_file.append(os.path.join(root,"coverage/dataset.cgf"))
#for path in os.listdir(cgf_dir):
#    if path != 'dataset.cgf':
#        full_path = os.path.join(cgf_dir, path)
#        if os.path.isfile(full_path):
#            cgf_file.append(full_path)

https_url = 'https://github.com/riscv/riscv-arch-test.git'
ssh_url = 'git@github.com:riscv/riscv-arch-test.git'

framework_db = os.path.join(root, "framework/database.yaml")
cwd = os.getcwd()
#work_dir = os.path.join(cwd, "riscof_work/")
html_template = os.path.join(root, 'Templates/report.html')
coverage_template = os.path.join(root, 'Templates/coverage.html')
css = os.path.join(root, 'Templates/style.css')
env = os.path.join(root, suite + "env/")

config_temp = '''[RISCOF]
ReferencePlugin={0}
ReferencePluginPath={1}
DUTPlugin={2}
DUTPluginPath={3}

[{2}]
pluginpath={3}
ispec={3}/{2}_isa.yaml
pspec={3}/{2}_platform.yaml
target_run=1

[{0}]
pluginpath={1}
'''

coverage_report_md = '''
|Covergroup|Coverage|
|:--------:|:------:|
{% for result in results %}|{{result.name}}|{{result.coverage}} ({{result.percentage}}%)|
{%endfor%}
'''


