import os

root = os.path.abspath(os.path.dirname(__file__))

suite = os.path.join(root,"suite/")
cgf_file = os.path.join(root,"suite/compliance.cgf")
framework_db = os.path.join(root, "framework/database.yaml")
cwd = os.getcwd()
work_dir = os.path.join(cwd, "riscof_work/")
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
'''


