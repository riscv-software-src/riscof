import random
import string


class pluginTemplate():

    def __init__(self, *args, **kwargs):
        self.name = kwargs.get(
            'name', ''.join(
                random.choices(string.ascii_uppercase + string.digits,
                               k=10))) + ":"

    def initialise(self, *args, **kwargs):
        pass

    def build(self, isa_yaml, platform_yaml, isa):
        pass

    def simulate(self, file, isa):
        pass

    def compile(self, file, macros, isa):
        pass
