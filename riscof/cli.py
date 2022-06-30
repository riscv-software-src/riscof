import click

import logging
import importlib
from datetime import datetime
import os
import sys
import pytz
import shutil
import configparser
import distutils.dir_util

from jinja2 import Template

#from riscof.log import *
from riscof.__init__ import __version__
import riscv_config.checker as checker
import riscof.framework.main as framework
import riscof.framework.test as test_routines
import riscof.arch_test as archtest
import riscof.dbgen as dbgen
import riscof.utils as utils
import riscof.constants as constants
from riscof.log import logger
from riscv_config.errors import ValidationError
import riscv_isac.coverage as isac
import riscv_isac
import riscv_config

class Context:
    mkdir = True
    config = None
    dut = None
    base = None
    config_dir = None
    isa_file = None
    platform_file = None

def setup_directories(work_dir,skip_rm=False):
    #Creating work directory
    if not os.path.exists(work_dir):
        logger.debug('Creating new work directory: ' + work_dir)
        os.mkdir(work_dir)
    elif not skip_rm:
        logger.debug('Removing old work directory: ' + work_dir)
        shutil.rmtree(work_dir)
        logger.debug('Creating new work directory: ' + work_dir)
        os.mkdir(work_dir)

def read_config(configfile):
    config = configparser.ConfigParser()
    logger.info("Reading configuration from: "+configfile)
    try:
        config.read(configfile)
    except FileNotFoundError as err:
        logger.error(err)
        raise SystemExit(1)
    return config,os.path.dirname(os.path.abspath(configfile))

def prepare_models(config_dir,config):
    riscof_config = config['RISCOF']
    logger.info("Preparing Models")
    try:
        dut_model = riscof_config['DUTPlugin']
        dut_model_path = utils.absolute_path(config_dir, riscof_config['DUTPluginPath'])

        base_model = riscof_config['ReferencePlugin']
        base_model_path = utils.absolute_path(config_dir, riscof_config['ReferencePluginPath'])
    except KeyError as key:
        logger.error("Error in config file. Possible missing keys.")
        logger.error(key)
        raise SystemExit(1)

    logger.debug("Importing " + dut_model + " plugin from: "+str(dut_model_path))
    sys.path.append(dut_model_path)
    try:
        dut_plugin = importlib.import_module("riscof_" + dut_model)
    except ImportError as msg:
        logger.error("Error while importing "+dut_model+".\n"+str(msg))
        raise SystemExit(1)
    dut_class = getattr(dut_plugin, dut_model)
    if dut_model in config:
        dut = dut_class(name="DUT", config=config[dut_model], config_dir=config_dir)
    else:
        dut = dut_class(name="DUT")

    logger.debug("Importing " + base_model + " plugin from: "+str(base_model_path))
    sys.path.append(base_model_path)
    try:
        base_plugin = importlib.import_module("riscof_" + base_model)
    except ImportError as msg:
        logger.error("Error while importing "+base_model+".\n"+str(msg))
        raise SystemExit(1)
    base_class = getattr(base_plugin, base_model)
    if base_model in config:
        base = base_class(name="Reference", config=config[base_model], config_dir=config_dir)
    else:
        base = base_class(name="Reference")
    return dut,base

def opt_to_name(opt):
    return (opt.replace("--","",1)).replace("-","_")

class CustomOption(click.Option):
    def __init__(self, *args, **kwargs):
        self.mutually_exclusive = set([opt_to_name(a) for a in kwargs.pop('mutually_exclusive', [])])
        self.requires = [set([opt_to_name(x) for x in a]) for a in kwargs.pop('requires', []) if a]
        help = kwargs.get('help', '')
        if self.mutually_exclusive:
            ex_str = ', '.join(self.mutually_exclusive)
            kwargs['help'] = help + (
                ' NOTE: This argument is mutually exclusive with '
                ' arguments: [' + ex_str + '].'
            )
        if self.requires:
            ex_str = '], ['.join([", ".join(a) for a in self.requires])
            kwargs['help'] = help + (
                ' NOTE: This argument requires one of the following sets of '
                ' arguments: [' + ex_str + '].'
            )
        super(CustomOption, self).__init__(*args, **kwargs)

    def handle_parse_result(self, ctx, opts, args):
        if self.mutually_exclusive.intersection(opts) and self.name in opts:
            raise click.UsageError(
                "Illegal usage: `{}` is mutually exclusive with "
                "arguments `{}`.".format(
                    self.name,
                    ', '.join(self.mutually_exclusive)
                )
            )
        if self.requires:
            if (not any([a.intersection(opts) == a for a in self.requires])) and self.name in opts:
                raise click.UsageError(
                    "Illegal usage: `{}` requires one of the following sets of arguments too "
                    "arguments [{}].".format(
                        self.name,
                        '], ['.join([", ".join(a) for a in self.requires])
                    )
                )

        return super(CustomOption, self).handle_parse_result(
            ctx,
            opts,
            args
        )


@click.group()
@click.version_option(prog_name="RISC-V Architectural Test Framework.",version=__version__)
@click.option('--verbose', '-v', default='info', help='Set verbose level', type=click.Choice(['info','error','debug'],case_sensitive=False))
@click.pass_context
def cli(ctx,verbose):
    logger.level(verbose)
    logger.info('****** RISCOF: RISC-V Architectural Test Framework {0} *******'.format(__version__ ))
    logger.info('using riscv_isac version : ' + str(riscv_isac.__version__))
    logger.info('using riscv_config version : ' + str(riscv_config.__version__))
    ctx.obj = Context()



@cli.command('validateyaml',help= 'Validate the Input YAMLs using riscv-config.')
@click.option('--config',type= click.Path(resolve_path=True,exists=True),
                        help='The Path to the config file. [Default=./config.ini]',
                        metavar= 'PATH',
                        default='./config.ini')
@click.option('--work-dir',default="./riscof_work",metavar='PATH',
        type=click.Path(resolve_path=True,writable=True),
        help='Path to the work directory.')
@click.pass_context
def validate(ctx,config,work_dir):
    if ctx.obj.mkdir:
        setup_directories(work_dir)
        ctx.obj.mkdir = False
    if ctx.obj.config is None:
        ctx.obj.config, ctx.obj.config_dir = read_config(config)
    if ctx.obj.dut is None:
        ctx.obj.dut,ctx.obj.base = prepare_models(ctx.obj.config_dir,ctx.obj.config)
    isa_file = ctx.obj.dut.isa_spec
    platform_file = ctx.obj.dut.platform_spec
    try:
        isa_file = checker.check_isa_specs( isa_file, work_dir, True)
        platform_file = checker.check_platform_specs( platform_file, work_dir, True)
    except ValidationError as msg:
        logger.error(msg)
        raise SystemExit(1)
    ctx.obj.isa_file = isa_file
    ctx.obj.platform_file = platform_file

@cli.command('gendb',help='Generate Database for the Suite.')
@click.option('--suite',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help="Path to the custom Suite Directory.")
@click.option('--env',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help='Path to the env directory for the suite.')
@click.option('--work-dir',default="./riscof_work",metavar='PATH',
    type=click.Path(resolve_path=True,writable=True),
    help='Path to the work directory. [Default = ./riscof_work]')
@click.pass_context
def generate(ctx,suite,env,work_dir):
    if ctx.obj.mkdir:
        setup_directories(work_dir)
        ctx.obj.mkdir = False

    logger.info("Generating database for suite: "+suite)
    constants.suite = suite
    constants.framework_db = os.path.join(work_dir,"database.yaml")
    logger.debug('Suite used: '+constants.suite)
    logger.debug('ENV used: '+ env)
    dbgen.generate()
    logger.info('Database File Generated: '+constants.framework_db)
    constants.env = env
    logger.info('Env path set to'+constants.env)

@cli.command('testlist',help='Generate the test list for the given DUT and suite.')
@click.option('--suite',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help="Path to the custom Suite Directory.")
@click.option('--env',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help='Path to the env directory for the suite.')
@click.option('--config',type= click.Path(resolve_path=True,exists=True),
                        help='The Path to the config file. [Default=./config.ini]',
                        metavar= 'PATH',
                        default='./config.ini')
@click.option('--work-dir',default="./riscof_work",metavar='PATH',
        type=click.Path(resolve_path=True,writable=True),
        help='Path to the work directory. [Default = ./riscof_work]')
@click.pass_context
def testlist(ctx,config,work_dir,suite,env):
    setup_directories(work_dir)
    ctx.obj.mkdir = False
    ctx.invoke(generate,suite=suite,env=env,work_dir=work_dir)
    ctx.obj.gendb = False
    ctx.obj.validate = False
    ctx.invoke(validate,config=config,work_dir=work_dir)
    isa_specs = utils.load_yaml(ctx.obj.isa_file)['hart0']
    platform_specs = utils.load_yaml(ctx.obj.platform_file)
    test_routines.generate_test_pool(isa_specs, platform_specs, work_dir)


@cli.command('run',help='Run the tests on DUT and reference and compare signatures')
@click.option('--suite',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help="Path to the custom Suite Directory.")
@click.option('--env',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help='Path to the env directory for the suite.')
@click.option('--config',type= click.Path(resolve_path=True,exists=True),
                        help='The Path to the config file. [Default=./config.ini]',
                        metavar= 'PATH',
                        default='./config.ini')
@click.option('--work-dir',default="./riscof_work",metavar='PATH',
        type=click.Path(resolve_path=True,writable=True),
        help='Path to the work directory.')
@click.option('--no-browser',is_flag=True,
                     help="Do not open the browser for showing the test report.")
@click.option('--dbfile',type= click.Path(resolve_path=True,exists=True),
                        help='The Path to the database file.',
                        metavar= 'PATH',cls=CustomOption,mutually_exclusive=['--testfile'])
@click.option('--testfile',
                        type= click.Path(resolve_path=True,exists=True),
                        help='The Path to the testlist file.',
                        metavar= 'PATH',cls=CustomOption,mutually_exclusive=['--dbfile'])
@click.option('--no-ref-run',is_flag=True,help="Do not run tests on Reference")
@click.option('--no-dut-run',is_flag=True,help="Do not run tests on DUT")
@click.option('--no-clean',is_flag=True,help="Do not clean work directory(if exists).")
@click.pass_context
def run(ctx,config,work_dir,suite,env,no_browser,dbfile,testfile,no_ref_run,no_dut_run,no_clean):
    exitcode = 0
    clean =  (testfile is not None or dbfile is not None or no_clean)
    setup_directories(work_dir,clean)
    ctx.obj.mkdir = False
    constants.env = env
    constants.suite = suite
    ctx.obj.config, ctx.obj.config_dir = read_config(config)
    ctx.obj.dut,ctx.obj.base = prepare_models(ctx.obj.config_dir,ctx.obj.config)

    dut = ctx.obj.dut
    base = ctx.obj.base

    if testfile is not None or dbfile is not None:
        if dbfile:
            constants.framework_db = dbfile
        else:
            constants.framework_db = os.path.join(work_dir,"database.yaml")
        isa_file = dut.isa_spec
        platform_file = dut.platform_spec
        isa_file = work_dir+ '/' + (isa_file.rsplit('/', 1)[1]).rsplit('.')[0] + "_checked.yaml"
        platform_file = work_dir+ '/' + (platform_file.rsplit('/', 1)[1]).rsplit('.')[0] + "_checked.yaml"
        ctx.obj.isa_file = isa_file
        ctx.obj.platform_file = platform_file
    else:
        ctx.invoke(validate,config=config,work_dir=work_dir)
        ctx.invoke(generate,suite=suite,env=env,work_dir=work_dir)


    with open(ctx.obj.isa_file, "r") as isafile:
        ispecs = isafile.read()
    isa_specs = utils.load_yaml(ctx.obj.isa_file)['hart0']

    with open(ctx.obj.platform_file, "r") as platfile:
        pspecs = platfile.read()

    cntr_args = [dbfile,testfile,no_ref_run,no_dut_run]

    report_objects = {}
    report_objects['date'] = (datetime.now(
        pytz.timezone('GMT'))).strftime("%Y-%m-%d %H:%M GMT")
    report_objects['riscof_version'] = __version__
    report_objects['dut'] = (dut.__model__).replace("_", " ")
    report_objects['reference'] = (base.__model__).replace("_", " ")

    rvarch, _ = archtest.get_version(constants.suite)
    report_objects['rvarch_version'] = rvarch['version'] if rvarch['version'] != "-" else \
                                        rvarch['commit']

    report_objects['isa'] = isa_specs['ISA']
    report_objects['usv'] = isa_specs['User_Spec_Version']
    report_objects['psv'] = isa_specs['Privilege_Spec_Version']
    report_objects['isa_yaml'] = ctx.obj.isa_file
    report_objects['platform_yaml'] = ctx.obj.platform_file
    report_objects['isa_specs'] = ispecs
    report_objects['platform_specs'] = pspecs

    report_objects['results'] = framework.run(dut, base, ctx.obj.isa_file,
                                              ctx.obj.platform_file, work_dir, cntr_args)

    report_objects['num_passed'] = 0
    report_objects['num_failed'] = 0

    for entry in report_objects['results']:
        if entry['res'] == "Passed":
            report_objects['num_passed'] += 1
        else:
            report_objects['num_failed'] += 1
            exitcode = 1

    with open(constants.html_template, "r") as report_template:
        template = Template(report_template.read())

    output = template.render(report_objects)

    reportfile = os.path.join(work_dir, "report.html")
    with open(reportfile, "w") as report:
        report.write(output)

    shutil.copyfile(constants.css,
                    os.path.join(work_dir, "style.css"))

    logger.info("Test report generated at "+reportfile+".")
    if not no_browser:
        try:
            import webbrowser
            logger.info("Opening test report in web-browser")
            webbrowser.open(reportfile)
            raise SystemExit(exitcode)
        except:
            raise SystemExit(exitcode)



@cli.command('coverage',help='Run the tests on DUT and reference and compare signatures')
@click.option('--suite',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help="Path to the custom Suite Directory.")
@click.option('--env',required=True,type=click.Path(resolve_path=True,exists=True),metavar="PATH",
    help='Path to the env directory for the suite.')
@click.option('--config',type= click.Path(resolve_path=True,exists=True),
                        help='The Path to the config file. [Default=./config.ini]',
                        metavar= 'PATH',
                        default='./config.ini')
@click.option('--work-dir',default="./riscof_work",metavar='PATH',
        type=click.Path(resolve_path=True,writable=True),
        help='Path to the work directory. [Default = ./riscof_work]')
@click.option('--no-browser',is_flag=True,
                     help="Do not open the browser for showing the test report.")
@click.option(
        '--cgf-file','-c',multiple=True,
        type=click.Path(resolve_path=True,readable=True,exists=True),
        help="Coverage Group File(s). Multiple allowed.",required=True
    )
@click.pass_context
def coverage(ctx,config,work_dir,suite,env,no_browser,cgf_file):
    setup_directories(work_dir)
    ctx.obj.mkdir = False
    ctx.obj.config, ctx.obj.config_dir = read_config(config)
    ctx.obj.dut,ctx.obj.base = prepare_models(ctx.obj.config_dir,ctx.obj.config)

    dut = ctx.obj.dut
    base = ctx.obj.base
    ctx.invoke(validate,config=config,work_dir=work_dir)
    ctx.invoke(generate,suite=suite,env=env,work_dir=work_dir)
    logger.info('Will collect Coverage using RISCV-ISAC')
    logger.info('CGF file(s) being used : ' + str(cgf_file))
    isa_file = ctx.obj.isa_file
    platform_file = ctx.obj.platform_file

    with open(isa_file, "r") as isafile:
        ispecs = isafile.read()
    isa_specs = utils.load_yaml(ctx.obj.isa_file)['hart0']

    with open(platform_file, "r") as platfile:
        pspecs = platfile.read()
    report, for_html, test_stats, coverpoints = framework.run_coverage(base, isa_file, platform_file,
            work_dir, cgf_file)
    report_file = open(work_dir+'/suite_coverage.rpt','w')
    utils.dump_yaml(report, report_file)
    report_file.close()


    report_objects = {}
    report_objects['date'] = (datetime.now(
        pytz.timezone('GMT'))).strftime("%Y-%m-%d %H:%M GMT")
    report_objects['riscof_version'] = __version__
    report_objects['reference'] = (base.__model__).replace("_", " ")

    rvarch, _ = archtest.get_version(constants.suite)
    report_objects['rvarch_version'] = rvarch['version'] if rvarch['version'] != "-" else \
                                        rvarch['commit']

    report_objects['isa'] = isa_specs['ISA']
    report_objects['usv'] = isa_specs['User_Spec_Version']
    report_objects['psv'] = isa_specs['Privilege_Spec_Version']
    report_objects['isa_yaml'] = isa_file
    report_objects['platform_yaml'] = platform_file
    report_objects['isa_specs'] = ispecs
    report_objects['platform_specs'] = pspecs
    report_objects['results'] = for_html
    report_objects['results1'] = test_stats
    report_objects['coverpoints'] = coverpoints
    with open(constants.coverage_template, "r") as report_template:
        template = Template(report_template.read())

    output = template.render(report_objects)

    reportfile = os.path.join(work_dir, "coverage.html")
    with open(reportfile, "w") as report:
        report.write(output)

    with open(reportfile.replace("html","md"),"w") as report_md:
        template = Template(constants.coverage_report_md)
        report_md.write(template.render(report_objects))

    shutil.copyfile(constants.css,
                    os.path.join(work_dir, "style.css"))

    logger.info("Test report generated at "+reportfile+".")
    if not no_browser:
        try:
            import webbrowser
            logger.info("Opening test report in web-browser")
            webbrowser.open(reportfile)
        except:
            raise SystemExit(0)



@cli.command('arch-test',help='Setup and maintenance for Architectural TestSuite.',
    no_args_is_help=True)
@click.option('--dir',type=click.Path(resolve_path=True),
    help="The Path to the directory to initialise/containing the tests. [Default = ./riscv-arch-test]",
    metavar = 'PATH',default="./riscv-arch-test")
@click.option('--get-version',type=str,default='latest',
    help=' Version of the repository to get. [Default = latest]',
    cls=CustomOption,requires=[['--clone'],['--update']])
@click.option('--clone',is_flag=True,
    help="Clone and setup the architectural tests from the remote repository.",cls=CustomOption,
    mutually_exclusive=["--update",'--show-version'])
@click.option('--update',is_flag=True,
    help="Update the architectural tests from the remote repository.",
    cls=CustomOption,mutually_exclusive=["--clone",'--show-version'])
@click.option('--show-version',is_flag=True,
    help="Print version of the local architectural test suite.",
    cls=CustomOption,mutually_exclusive=['--clone','--update'])
def arch_test(dir,get_version,clone,update,show_version):
    if(clone):
        if os.path.exists(dir):
            shutil.rmtree(dir)
        archtest.clone(dir,get_version)
    elif(update):
        archtest.update(dir,get_version)
    elif(show_version):
        version, is_repo = archtest.get_version(dir)
        if not is_repo:
            logger.error("Not the riscv-arch-test repo.")
        else:
            logger.info("Clonned version {0} of the repository with commit hash {1} ".format(
                    version['version'],version['commit']))
    else:
        logger.error("Please specify one of [update,clone,show-version] flags.")



@cli.command('setup',help='Initiate Setup for riscof.')
@click.option('--dutname',type=str,help='Name of DUT plugin. [Default=spike]',
    default='spike',metavar= 'NAME')
@click.option('--refname',type=str,help='Name of Reference plugin. [Default=sail_cSim]',
    default='sail_cSim',metavar= 'NAME')
@click.option('--work-dir',default="./riscof_work",metavar='PATH',
        type=click.Path(resolve_path=True,writable=True),
        help='Path to the work directory.')
def setup(dutname,refname,work_dir):
    logger.info("Setting up sample plugin requirements [Old files will be overwritten]")
    try:
        cwd = os.getcwd()
        logger.info("Creating sample Plugin directory for [DUT]: " +dutname)
        src = os.path.join(constants.root, "Templates/setup/model/")
        dest = os.path.join(cwd, dutname)
        distutils.dir_util.copy_tree(src, dest)

        os.rename(cwd+'/'+dutname+'/model_isa.yaml',
                cwd+'/'+dutname+'/'+dutname+'_isa.yaml')
        os.rename(cwd+'/'+dutname+'/model_platform.yaml',
                cwd+'/'+dutname+'/'+dutname+'_platform.yaml')
        os.rename(cwd+'/'+dutname+'/riscof_model.py',
                cwd+'/'+dutname+'/riscof_'+dutname+'.py')
        with open(cwd+'/'+dutname+'/riscof_'+dutname+'.py', 'r') as file :
          filedata = file.read()

        # Replace the target string
        filedata = filedata.replace('dutname', dutname)

        # Write the file out again
        with open(cwd+'/'+dutname+'/riscof_'+dutname+'.py', 'w') as file:
          file.write(filedata)

        logger.info("Creating sample Plugin directory for [REF]: " +\
              refname)
        if refname == 'sail_cSim':
            src = os.path.join(constants.root, "Templates/setup/sail_cSim/")
            dest = os.path.join(cwd, refname)
            distutils.dir_util.copy_tree(src, dest)
        else:
            src = os.path.join(constants.root, "Templates/setup/reference/")
            dest = os.path.join(cwd, refname)
            distutils.dir_util.copy_tree(src, dest)
            os.rename(cwd+'/'+refname+'/riscof_model.py',
                cwd+'/'+refname+'/riscof_'+refname+'.py')
            with open(cwd+'/'+refname+'/riscof_'+refname+'.py', 'r') as file :
              filedata = file.read()

            # Replace the target string
            filedata = filedata.replace('refname', refname)

            # Write the file out again
            with open(cwd+'/'+refname+'/riscof_'+refname+'.py', 'w') as file:
              file.write(filedata)

        logger.info("Creating Sample Config File")
        configfile = open('config.ini','w')
        configfile.write(constants.config_temp.format(refname, \
                cwd+'/'+refname, dutname,cwd+'/'+dutname))
        logger.info('**NOTE**: Please update the paths of the reference \
and plugins in the config.ini file')
        configfile.close()
    except FileExistsError as err:
        logger.error(err)
        raise SystemExit(1)

if __name__=="__main__":
    cli()
