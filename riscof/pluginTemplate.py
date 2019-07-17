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
    def simulate(self, file):
        """Use the model to simulate the elf for the given file.
            
            :return: The absolute path to the signature file generated.
            
            :param file: The test file path relative to the riscof directory.
            
            :type file: str
        """
        logger.debug(self.name + "Simulate")
        pass

    @abstractmethod
    def compile(self, file, isa, macros):
        """
            Compile the test file and produce the elf at the 
            correct place(workdir/testname/testname.elf).
            
            :param file: The test file path relative to the riscof directory.
            
            :param isa: The isa(Adhering to the RISCV specs) which can be used 
                to derive complier options as required.
            
            :param macros: The list of macros to be defined while compiling.

            :type file: str
            
            :type macros: list
            
            :type isa: str
        """
        logger.debug(self.name + "Compile")
        pass

    def getname(self):
        return self._role + "-" + self.__model__ + ":"

    def setname(self, role):
        self._role = role

    name = property(getname, setname)
