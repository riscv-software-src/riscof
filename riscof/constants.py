import os

root = os.path.abspath(os.path.dirname(__file__))

isa_schema = os.path.join(root, 'schemas/isa.yaml')
platform_schema = os.path.join(root, 'schemas/platform.yaml')
suite = "suite/"
framework_db = os.path.join(root, "framework/database.yaml")
cwd = os.getcwd()
work_dir = os.path.join(cwd, "riscof_work/")
html_template = os.path.join(root, 'Templates/report.html')
css = os.path.join(root, 'Templates/style.css')
env = os.path.join(root, suite + "env/")
