import random
import string
import logging
from abc import abstractmethod, ABC

logger = logging.getLogger(__name__)


class pluginTemplate(ABC):
    """
        Metaclass for plugins as supported by :py:mod:`ABC`.
    """
    __model__ = "Template"

    @abstractmethod
    def __init__(self, *args, **kwargs):
        """
            Constructor.
            
            :param name: (passed as kwarg) Name to be displayed in the logger.
            
            :param config: (passed as kwarg) The configuration for the plugin as specified in the conifig.ini file.

            :type config: dict

            :type name: str
        """
        self.name = kwargs.get(
            'name',
            ''.join(random.choices(string.ascii_uppercase + string.digits,
                                   k=10)))

    @abstractmethod
    def initialise(self, suite, workdir, env):
        """
            Initialise the plugin with neccessary parameters.
            
            :param suite: The name of the suite directory.This is used to replace the name of the file to create 
                directories in proper order.
            
            :param workdir: The absolute path to the work directory.

            :param env: The directory containing the header files for the tests.

            :type suite: str

            :type workdir: str
            
            :type env: str
        """
        logger.debug(self.name + "Initialise")
        pass

    @abstractmethod
    def build(self, isa_yaml, platform_yaml):
        """
            Build the model as per specifications specified by DUT.
            
            :param isa_yaml: Path to the checked isa specs yaml.
            
            :param platform_yaml: Path to the checked platform specs yaml.
            
            :type isa_yaml: str
            
            :type platform_yaml: str
        """
        logger.debug(self.name + "Build")
        pass

    @abstractmethod
    def runTests(self, testlist):
        """Use the model to run the tests and produce signatures. The signature files generated should be named-*self.name[:-1]+".signature"*.
            
            :param testlist: A dictionary of tests and other information about them(like macros,work_dir and isa).
            
            :type testlist: dict
        """
        logger.debug(self.name + "Test Run")
        pass

    def getname(self):
        return self._role + "-" + self.__model__ + ":"

    def setname(self, role):
        self._role = role

    name = property(getname, setname)
