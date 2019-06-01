import oyaml as yaml
import importlib
import common.utils as utils
import logging
import shutil
import os

def test():
    # Set up the logger
    utils.setup_logging("debug")
    logger = logging.getLogger()
    logger.handlers = []
    ch = logging.StreamHandler()
    ch.setFormatter(utils.ColoredFormatter())
    logger.addHandler(ch)

    schema_yaml = utils.loadyaml("Examples/template_env.yaml")
    module = importlib.import_module('plugin.model_from_yaml')
    my_class = getattr(module, 'model_from_yaml')
    my_instance = my_class()

    work_dir = os.getcwd()+"/work/"
    suite = os.getcwd()+"/suite/"
    #Creating work directory
    if not os.path.exists(work_dir):
        logger.debug('Creating new work directory: '+work_dir)
        os.mkdir(work_dir)
    else:
        logger.debug('Removing old work directory: '+work_dir)
        shutil.rmtree(work_dir)
        logger.debug('Creating new work directory: '+work_dir)
        os.mkdir(work_dir)

    schema = "Examples/template_env.yaml"
    my_instance.initialise_from_file(schema,work_dir=work_dir,suite=suite)
    my_instance.compile("I-SB-01"," -DTEST_PART_1=True")
    k = my_instance.simulate("I-SB-01")
    print(k)
if __name__ == '__main__':
    test()