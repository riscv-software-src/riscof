import logging
import importlib
import shutil
import os

import riscof.framework.test as test
#from riscof.framework.test import run_tests
import riscof.utils as utils
import riscof.constants as constants
import riscv_isac.coverage as isac
import ruamel
from ruamel.yaml import YAML
from elftools.elf.elffile import ELFFile
yaml = YAML(typ="rt")
yaml.default_flow_style = False
yaml.allow_unicode = True

logger = logging.getLogger(__name__)

def filter_coverage(cgf_file,ispec,pspec,results):
    cgf = utils.load_yaml(cgf_file)
    spec = {**ispec,**pspec}
    cover_points = []
    for key,node in cgf.items():
        if key == 'datasets':
            continue
        include = True
        if 'config' in node:
            for entry in node['config'].split(";"):
                if 'check' in entry:
                    include = include and test.eval_cond(entry, spec)
        if include:
            cover_points.append(key)
    result_filtered = {}
    for key in cover_points:
        result_filtered[key] = results[key]
    return result_filtered

def find_elf_size(elf):
    with open(elf, 'rb') as f:
        elffile = ELFFile(f)
        # elfclass is a public attribute of ELFFile, read from its header
        symtab = elffile.get_section_by_name('.symtab')
        e_ehsize = elffile.header['e_ehsize']
        e_phnum = elffile.header['e_phnum']
        e_phentsize = elffile.header['e_phentsize']
        e_shnum = elffile.header['e_shnum']
        e_shentsize = elffile.header['e_shentsize']
        e_shoff = elffile.header['e_shoff']
        size = e_shoff + e_ehsize + (e_phnum * e_phentsize) + (e_shnum * e_shentsize)
    return size

def run_coverage(base, dut_isa_spec, dut_platform_spec, cgf_file=None):
    '''
        Entry point for the framework module. This function initializes and sets up the required
        variables for the tests to run.

        :param dut: The class instance for the DUT model.

        :param base: The class instance for the BASE model.

        :param dut_isa_spec: The absolute path to the checked yaml containing
            the DUT isa specification.

        :param dut_platform_spec: The absolute path to the checked yaml containing
            the DUT platform specification.

        :type dut_platform_spec: str

        :type dut_isa_spec: str

        :return: A list of dictionary objects containing the necessary information
            required to generate the report given from the :py:mod:`riscof.framework.test` module.

    '''
    work_dir = constants.work_dir

    # Setting up models
    base.initialise(constants.suite, work_dir, constants.env)
    #Loading Specs
    ispec = utils.load_yaml(dut_isa_spec)
    pspec = utils.load_yaml(dut_platform_spec)

    logger.debug("Running Build for Reference")
    base.build(dut_isa_spec, dut_platform_spec)

    test_list, test_pool = test.generate_test_pool(ispec, pspec)
    logger.info("Running Tests on Reference.")
    base.runTests(test_list, cgf_file)

    logger.info("Merging Coverage reports")
    cov_files = []
    test_stats = []
    for entry in test_pool:
        work_dir = test_list[entry[0]]['work_dir']
        cov_files.append(os.path.join(test_list[entry[0]]['work_dir'],'dump.cgf'))
        elf = work_dir + '/my.elf'
        test_stats.append( {'test_name': entry[0], 
                            'test_size': str(find_elf_size(elf)),
                            'test_groups': str(test_list[entry[0]]['coverage_labels'])
                            })

    if 64 in ispec['supported_xlen']:
        results = isac.merge_coverage(cov_files, cgf_file, True, 64)
    elif 32 in ispec['supported_xlen']:
        results = isac.merge_coverage(cov_files, cgf_file, True, 32)


    results_yaml = yaml.load(results)
    results_yaml = filter_coverage(cgf_file,ispec,pspec,results_yaml)
    for_html = []
    for cov_labels in results_yaml:
        coverage = results_yaml[cov_labels]['coverage']
        string = isac.pretty_print_yaml(results_yaml[cov_labels])
        percentage = "{:.2f}".format(eval(coverage)*100)
        res = {
                'name': cov_labels,
                'coverage': coverage,
                'log': string,
                'percentage': percentage,
                }
        for_html.append(res)

    return results, for_html, test_stats

def run(dut, base, dut_isa_spec, dut_platform_spec):
    '''
        Entry point for the framework module. This function initializes and sets up the required
        variables for the tests to run.

        :param dut: The class instance for the DUT model.

        :param base: The class instance for the BASE model.

        :param dut_isa_spec: The absolute path to the checked yaml containing
            the DUT isa specification.

        :param dut_platform_spec: The absolute path to the checked yaml containing
            the DUT platform specification.

        :type dut_platform_spec: str

        :type dut_isa_spec: str

        :return: A list of dictionary objects containing the necessary information
            required to generate the report given from the :py:mod:`riscof.framework.test` module.

    '''
    work_dir = constants.work_dir

    # Setting up models
    dut.initialise(constants.suite, work_dir, constants.env)
    base.initialise(constants.suite, work_dir, constants.env)
    #Loading Specs
    ispec = utils.load_yaml(dut_isa_spec)
    pspec = utils.load_yaml(dut_platform_spec)

    logger.debug("Running Build for DUT")
    dut.build(dut_isa_spec, dut_platform_spec)
    logger.debug("Running Build for Reference")
    base.build(dut_isa_spec, dut_platform_spec)

    results = test.run_tests(dut, base, ispec, pspec)

    return results


if __name__ == '__main__':
    run()
