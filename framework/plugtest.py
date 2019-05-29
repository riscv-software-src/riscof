import oyaml as yaml
import importlib
import common.utils as utils
import logging

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

    schema = "Examples/template_env.yaml"
    my_instance.initialise_from_file(schema)
    my_instance.compile("I-SB-01"," -DTEST_PART_1=True")
    my_instance.presim("I-SB-01")
    my_instance.simulate("I-SB-01")
    my_instance.postsim("I-SB-01")

if __name__ == '__main__':
    test()