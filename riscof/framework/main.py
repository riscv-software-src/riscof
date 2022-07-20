import logging
import importlib
import shutil
import os

import riscof.framework.test as test
#from riscof.framework.test import run_tests
import riscof.utils as utils
import riscof.constants as constants
import riscv_isac.coverage as isac
from riscv_isac.utils import load_cgf
from riscv_isac.cgf_normalize import expand_cgf
import ruamel
from ruamel.yaml import YAML
from elftools.elf.elffile import ELFFile
yaml = YAML(typ="rt")
yaml.default_flow_style = False
yaml.allow_unicode = True

import pprint
pp = pprint.PrettyPrinter(indent=4)

logger = logging.getLogger(__name__)

def filter_coverage(cgf_file,ispec,pspec,results):
    cgf = load_cgf(cgf_file)
    spec = {**ispec,**pspec}
    cover_points = []
    for key,node in cgf.items():
        if key == 'datasets':
            continue
        include_node = False
        if 'cond' in node:
            for entry in node['cond'].split(";"):
                if 'check' in entry:
                    include_node = include_node or test.eval_cond(entry, spec)
        elif 'config' in node:
            for entry in node['config']:
                include_entry = True
                for cond in entry.split(";"):
                    if 'check' in cond:
                        include_entry = include_entry and test.eval_cond(cond, spec)
                include_node = include_node or include_entry
        if include_node:
            cover_points.append(key)
    result_filtered = {}
    for key in cover_points:
        result_filtered[key] = results[key]
    return result_filtered

def get_addr_from_symtab(symtab,label):
    mains = symtab.get_symbol_by_name(label)
    if mains is not None:
        main = mains[0]
        return int(main.entry['st_value'])
    else:
        return 0
def find_elf_size(elf):
    with open(elf, 'rb') as f:
        elffile = ELFFile(f)
        symtab = elffile.get_section_by_name('.symtab')
        code_size = get_addr_from_symtab(symtab,'rvtest_code_end') - get_addr_from_symtab(symtab,'rvtest_code_begin')
        data_size = get_addr_from_symtab(symtab,'rvtest_data_end') - get_addr_from_symtab(symtab,'rvtest_data_begin')
        sign_size = get_addr_from_symtab(symtab,'end_signature') - get_addr_from_symtab(symtab,'begin_signature')
        # size = 0
        # for segment in elffile.iter_segments():
        #     size += segment['p_memsz']
        # elfclass is a public attribute of ELFFile, read from its header
        # symtab = elffile.get_section_by_name('.symtab')
        # e_ehsize = elffile.header['e_ehsize']
        # e_phnum = elffile.header['e_phnum']
        # e_phentsize = elffile.header['e_phentsize']
        # e_shnum = elffile.header['e_shnum']
        # e_shentsize = elffile.header['e_shentsize']
        # e_shoff = elffile.header['e_shoff']
        # size = e_shoff + e_ehsize + (e_phnum * e_phentsize) + (e_shnum * e_shentsize)
        return (sum([segment['p_memsz'] for segment in elffile.iter_segments()]),code_size,data_size,sign_size)

def run_coverage(base, dut_isa_spec, dut_platform_spec, work_dir, cgf_file=None):
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
#    work_dir = constants.work_dir
    # Setting up models
    base.initialise(constants.suite, work_dir, constants.env)
    #Loading Specs
    ispec = utils.load_yaml(dut_isa_spec)['hart0']
    pspec = utils.load_yaml(dut_platform_spec)

    logger.debug("Running Build for Reference")
    base.build(dut_isa_spec, dut_platform_spec)

    test_list, test_pool = test.generate_test_pool(ispec, pspec, work_dir)
    logger.info("Running Tests on Reference.")
    base.runTests(test_list, cgf_file)


    logger.info("Merging Coverage reports")
    cov_files = []
    test_stats = []
    for entry in test_pool:
        work_dir = test_list[entry[0]]['work_dir']
        test_name = work_dir.rsplit('/',1)[1][:-2]
        cov_files.append(os.path.join(test_list[entry[0]]['work_dir'],'ref.cgf'))
        elf = work_dir + '/ref.elf'
        test_stats.append( {'test_name': entry[0],
                            'test_size': [str(entry) for entry in find_elf_size(elf)],
                            'test_groups': str(set(test_list[entry[0]]['coverage_labels']))
                            })
    flen = 0
    if 'F' in ispec['ISA']:
        flen = 32
    if 'D' in ispec['ISA']:
        flen = 64
    if 64 in ispec['supported_xlen']:
        results = isac.merge_coverage(cov_files, expand_cgf(cgf_file,64,flen), True)
    elif 32 in ispec['supported_xlen']:
        results = isac.merge_coverage(cov_files, expand_cgf(cgf_file,32,flen), True)


#    results_yaml = yaml.load(results)
    results_yaml = filter_coverage(cgf_file,ispec,pspec,results)
    for_html = []
    coverpoints = 0
    for cov_labels in results_yaml:
        coverage = results_yaml[cov_labels]['total_coverage']
        coverpoints += int(coverage.split('/')[1])
        string = isac.pretty_print_yaml(results_yaml[cov_labels])
        percentage = "{:.2f}".format(eval(coverage)*100)
        res = {
                'name': cov_labels,
                'coverage': coverage,
                'log': string,
                'percentage': percentage,
                }
        for_html.append(res)

    return results, for_html, test_stats, coverpoints

def run(dut, base, dut_isa_spec, dut_platform_spec, work_dir, cntr_args):
    '''
        Entry point for the framework module. This function initializes and sets up the required
        variables for the tests to run.

        :param dut: The class instance for the DUT model.

        :param base: The class instance for the BASE model.

        :param dut_isa_spec: The absolute path to the checked yaml containing
            the DUT isa specification.

        :param dut_platform_spec: The absolute path to the checked yaml containing
            the DUT platform specification.

        :param cntr_args: dbfile, testfile, no_ref_run, no_dut_run

        :type dut_platform_spec: str

        :type dut_isa_spec: str

        :return: A list of dictionary objects containing the necessary information
            required to generate the report given from the :py:mod:`riscof.framework.test` module.

    '''
#    work_dir = constants.work_dir

    # Setting up models
    dut.initialise(constants.suite, work_dir, constants.env)
    base.initialise(constants.suite, work_dir, constants.env)
    #Loading Specs
    ispec = utils.load_yaml(dut_isa_spec)
    pspec = utils.load_yaml(dut_platform_spec)

    if cntr_args[2]:
        logger.info("Running Build for DUT")
        dut.build(dut_isa_spec, dut_platform_spec)
    elif cntr_args[3]:
        logger.info("Running Build for Reference")
        base.build(dut_isa_spec, dut_platform_spec)
    else:
        logger.info("Running Build for DUT")
        dut.build(dut_isa_spec, dut_platform_spec)
        logger.info("Running Build for Reference")
        base.build(dut_isa_spec, dut_platform_spec)

    results = test.run_tests(dut, base, ispec['hart0'], pspec, work_dir, cntr_args)

    return results


if __name__ == '__main__':
    run()
