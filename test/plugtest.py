import oyaml as yaml
import importlib
# import plugin.fromSchema as module
def kk():
    print('k')

def test():
    file = open("test/test.yaml","r")
    schema_yaml = yaml.safe_load(file)
    module = importlib.import_module('plugin.fromSchema')
    my_class = getattr(module, 'fromSchema')
    my_instance = my_class()

    my_instance.initialise(schema_yaml)
    my_instance.presim("I-SB-01")
    my_instance.execute("I-SB-01"," -DTEST_PART_1=True")
    my_instance.postsim("I-SB-01")

if __name__ == '__main__':
    test()