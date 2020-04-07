import pathlib
import logging
import argparse
import os
import sys
import subprocess
import operator
import shlex
import ruamel
from ruamel.yaml import YAML

logger = logging.getLogger(__name__)

yaml = YAML(typ="rt")
yaml.default_flow_style = False
yaml.allow_unicode = True


def load_yaml(foo):
    try:
        with open(foo, "r") as file:
            return dict(yaml.load(file))
    except ruamel.yaml.constructor.DuplicateKeyError as msg:
        logger = logging.getLogger(__name__)
        error = "\n".join(str(msg).split("\n")[2:-7])
        logger.error(error)
        raise SystemExit




class makeUtil():
    """
    Utility for ease of use of make commands like `make` and `pmake`.
    Supports automatic addition and execution of targets. Uses the class
    :py:class:`shellCommand` to execute commands.
    """
    def __init__(self,makeCommand='make',makefilePath="./Makefile"):
        """ Constructor.

        :param makeCommand: The variant of make to be used with optional arguments.
            Ex - `pmake -j 8`

        :type makeCommand: str

        :param makefilePath: The path to the makefile to be used.

        :type makefilePath: str

        """
        self.makeCommand=makeCommand
        self.makefilePath = makefilePath
        self.targets = []
    def add_target(self,command,tname=""):
        """
        Function to add a target to the makefile.

        :param command: The command to be executed when the target is run.

        :type command: str

        :param tname: The name of the target to be used. If not specified, TARGET<num> is used as the name.

        :type tname: str
        """
        if tname == "":
            tname = "TARGET"+str(len(self.targets))
        with open(self.makefilePath,"a") as makefile:
            makefile.write("\n\n.PHONY : " + tname + "\n" + tname + " :\n\t"+command.replace("\n","\n\t"))
            self.targets.append(tname)
    def execute_target(self,tname,cwd="./"):
        """
        Function to execute a particular target only.

        :param tname: Name of the target to execute.

        :type tname: str

        :param cwd: The working directory to be set while executing the make command.

        :type cwd: str

        :raise AssertionError: If target name is not present in the list of defined targets.

        """
        assert tname in self.targets, "Target does not exist."
        shellCommand(self.makeCommand+" -f "+self.makefilePath+" "+tname).run(cwd=cwd)
    def execute_all(self,cwd):
        """
        Function to execute all the defined targets.

        :param cwd: The working directory to be set while executing the make command.

        :type cwd: str

        """
        shellCommand(self.makeCommand+" -f "+self.makefilePath+" "+" ".join(self.targets)).run(cwd=cwd)


class Command():
    """
    Class for command build which is supported
    by :py:mod:`suprocess` module. Supports automatic
    conversion of :py:class:`pathlib.Path` instances to
    valid format for :py:mod:`subprocess` functions.
    """

    def __init__(self, *args, pathstyle='auto', ensure_absolute_paths=False):
        """Constructor.

        :param pathstyle: Determine the path style when adding instance of
            :py:class:`pathlib.Path`. Path style determines the slash type
            which separates the path components. If pathstyle is `auto`, then
            on Windows backslashes are used and on Linux forward slashes are used.
            When backslashes should be prevented on all systems, the pathstyle
            should be `posix`. No other values are allowed.

        :param ensure_absolute_paths: If true, then any passed path will be
            converted to absolute path.

        :param args: Initial command.

        :type pathstyle: str

        :type ensure_absolute_paths: bool
        """
        self.ensure_absolute_paths = ensure_absolute_paths
        self.pathstyle = pathstyle
        self.args = []

        for arg in args:
            self.append(arg)

    def append(self, arg):
        """Add new argument to command.

        :param arg: Argument to be added. It may be list, tuple,
            :py:class:`Command` instance or any instance which
            supports :py:func:`str`.
        """
        to_add = []
        if type(arg) is list:
            to_add = arg
        elif type(arg) is tuple:
            to_add = list(arg)
        elif isinstance(arg, type(self)):
            to_add = arg.args
        elif isinstance(arg, str) and not self._is_shell_command():
            to_add = shlex.split(arg)
        else:
            # any object which will be converted into str.
            to_add.append(arg)

        # Convert all arguments to its string representation.
        # pathlib.Path instances
        to_add = [
            self._path2str(el) if isinstance(el, pathlib.Path) else str(el)
            for el in to_add
        ]
        self.args.extend(to_add)

    def clear(self):
        """Clear arguments."""
        self.args = []

    def run(self, **kwargs):
        """Execute the current command.

        Uses :py:class:`subprocess.Popen` to execute the command.

        :return: The return code of the process     .
        :raise subprocess.CalledProcessError: If `check` is set
                to true in `kwargs` and the process returns
                non-zero value.
        """
        kwargs.setdefault('shell', self._is_shell_command())
        cwd = self._path2str(kwargs.get(
            'cwd')) if not kwargs.get('cwd') is None else self._path2str(
                os.getcwd())
        kwargs.update({'cwd': cwd})
        logger.debug(cwd)
        # When running as shell command, subprocess expects
        # The arguments to be string.
        logger.debug(str(self))
        cmd = str(self) if kwargs['shell'] else self
        x = subprocess.Popen(cmd,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE,
                             **kwargs)
        out, err = x.communicate()
        out = out.rstrip()
        err = err.rstrip()
        if x.returncode != 0:
            if out:
                logger.error(out.decode("ascii"))
            if err:
                logger.error(err.decode("ascii"))
        else:
            if out:
                logger.warning(out.decode("ascii"))
            if err:
                logger.warning(err.decode("ascii"))
        return x.returncode

    def _is_shell_command(self):
        """
        Return true if current command is supposed to be executed
        as shell script otherwise false.
        """
        return any('|' in arg for arg in self.args)

    def _path2str(self, path):
        """Convert :py:class:`pathlib.Path` to string.

        The final form of the string is determined by the
        configuration of `Command` instance.

        :param path: Path-like object which will be converted
                     into string.
        :return: String representation of `path`
        """
        path = pathlib.Path(path)
        if self.ensure_absolute_paths and not path.is_absolute():
            path = path.resolve()

        if self.pathstyle == 'posix':
            return path.as_posix()
        elif self.pathstyle == 'auto':
            return str(path)
        else:
            raise ValueError(f"Invalid pathstyle {self.pathstyle}")

    def __add__(self, other):
        cmd = Command(self,
                      pathstyle=self.pathstyle,
                      ensure_absolute_paths=self.ensure_absolute_paths)
        cmd += other
        return cmd

    def __iadd__(self, other):
        self.append(other)
        return self

    def __iter__(self):
        """
        Support iteration so functions from :py:mod:`subprocess` module
        support `Command` instance.
        """
        return iter(self.args)

    def __repr__(self):
        return f'<{self.__class__.__name__} args={self.args}>'

    def __str__(self):
        return ' '.join(self.args)


class shellCommand(Command):
    """
        Sub Class of the command class which always executes commands as shell commands.
    """

    def __init__(self, *args, pathstyle='auto', ensure_absolute_paths=False):
        """
        :param pathstyle: Determine the path style when adding instance of
            :py:class:`pathlib.Path`. Path style determines the slash type
            which separates the path components. If pathstyle is `auto`, then
            on Windows backslashes are used and on Linux forward slashes are used.
            When backslashes should be prevented on all systems, the pathstyle
            should be `posix`. No other values are allowed.

        :param ensure_absolute_paths: If true, then any passed path will be
            converted to absolute path.

        :param args: Initial command.

        :type pathstyle: str

        :type ensure_absolute_paths: bool

        """
        return super().__init__(*args,
                                pathstyle=pathstyle,
                                ensure_absolute_paths=ensure_absolute_paths)

    def _is_shell_command(self):
        return True


class ColoredFormatter(logging.Formatter):
    """
        Class to create a log output which is colored based on level.
    """

    def __init__(self, *args, **kwargs):
        super(ColoredFormatter, self).__init__(*args, **kwargs)
        self.colors = {
            'DEBUG': '\033[94m',
            'INFO': '\033[92m',
            'WARNING': '\033[93m',
            'ERROR': '\033[91m',
        }

        self.reset = '\033[0m'

    def format(self, record):
        msg = str(record.msg)
        level_name = str(record.levelname)
        name = str(record.name)
        color_prefix = self.colors[level_name]
        return '{0}{1:<9s} : {2}{3}'.format(color_prefix,
                                            '[' + level_name + ']', msg,
                                            self.reset)


def setup_logging(log_level):
    """Setup logging

        Verbosity decided on user input

        :param log_level: User defined log level

        :type log_level: str
    """
    numeric_level = getattr(logging, log_level.upper(), None)

    if not isinstance(numeric_level, int):
        print(
            "\033[91mInvalid log level passed. Please select from debug | info | warning | error\033[0m"
        )
        raise ValueError("{}-Invalid log level.".format(log_level))

    logging.basicConfig(level=numeric_level)


class SortingHelpFormatter(argparse.HelpFormatter):
    def add_arguments(self, actions):
        actions = sorted(actions, key=operator.attrgetter('option_strings'))
        super(SortingHelpFormatter, self).add_arguments(actions)


class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        raise SystemExit
    def format_help(self):
        formatter = self._get_formatter()

        # usage
        formatter.add_usage(self.usage, self._actions,
                            self._mutually_exclusive_groups)

        # description
        formatter.add_text(self.description)

        # positionals, optionals and user-defined groups
        for action_group in self._action_groups:
            formatter.start_section(action_group.title)
            formatter.add_text(action_group.description)
            formatter.add_arguments(action_group._group_actions)
            formatter.end_section()

        # epilog
        formatter.add_text(self.epilog)

        # determine help from format above
        return formatter.format_help()
    def print_help(self,file=None):
        if file is None:
            file = sys.stdout
        self._print_message(self.format_help(), file)
        subparsers_actions = [
        action for action in self._actions
        if isinstance(action, argparse._SubParsersAction)]
        for subparsers_action in subparsers_actions:
            for choice, subparser in subparsers_action.choices.items():
               self._print_message("Action '{}'\n\n".format(choice),file)
               self._print_message("\t"+(subparser.format_help()).replace("\n","\n\t")+"\n",file)

def riscof_cmdline_args():
    parser = MyParser(
        formatter_class=SortingHelpFormatter,
        prog="riscof",
        description="This program checks compliance for a DUT.")
    parser.add_argument('--version','-v',
                        help='Print version of RISCOF being used',
                        action='store_true')
    parser.add_argument('--verbose',
                        action='store',
                        default='info',
                        choices = ['debug','info','warning','error'],
                        help='[Default=info]',
                        metavar="")
    subparsers = parser.add_subparsers(dest='command',title="Action",description="The action to be performed by riscof.",help="List of actions supported by riscof.")

    generatedb = subparsers.add_parser('gendb',help='Generate Database for the standard suite.',formatter_class=SortingHelpFormatter)
    generatedb.add_argument('--suite',
                            type= lambda p: str(pathlib.Path(p).absolute()),
                            action='store',
                            help='The Path to the custom suite directory.',
                            metavar= 'PATH')
    setup = subparsers.add_parser('setup',help='Initiate setup for riscof.',formatter_class=SortingHelpFormatter)
    setup.add_argument('--dutname',
                        action='store',
                        help='Name of DUT plugin. [Default=spike]',
                        default='spike',
                        metavar= 'NAME')
    setup.add_argument('--refname',
                        action='store',
                        help='Name of Reference plugin. [Default=riscvOVPsim]',
                        default='riscvOVPsim',
                        metavar= 'NAME')
    validate = subparsers.add_parser('validateyaml',
                        help='Validate the Input YAMLs using riscv-config.',formatter_class=SortingHelpFormatter)
    validate.add_argument('--config',
                        type= lambda p: str(pathlib.Path(p).absolute()),
                        action='store',
                        help='The Path to the config file. [Default=./config.ini]',
                        metavar= 'PATH',
                        default=str(pathlib.Path('./config.ini').absolute())
                          )
    run = subparsers.add_parser('run',
                        help='Run the tests on DUT and reference and compare signatures.',formatter_class=SortingHelpFormatter)
    run.add_argument('--config',
                        type= lambda p: str(pathlib.Path(p).absolute()),
                        action='store',
                        help='The Path to the config file. [Default=./config.ini]',
                        metavar= 'PATH',
                        default=str(pathlib.Path('./config.ini').absolute())
                          )
    run.add_argument('--suite',
                        type= lambda p: str(pathlib.Path(p).absolute()),
                        action='store',
                        help='The Path to the custom suite directory.',
                        metavar= 'PATH')
    run.add_argument('--no-browser',action='store_true',
                     help="Do not open the browser for showing the test report.")
    testlist = subparsers.add_parser('testlist',
                        help='Generate the test list for the given DUT and suite. Uses the compliance suite by default.',formatter_class=SortingHelpFormatter)
    testlist.add_argument('--config',
                        type= lambda p: str(pathlib.Path(p).absolute()),
                        action='store',
                        help='The Path to the config file. [Default=./config.ini]',
                        metavar= 'PATH',
                        default=str(pathlib.Path('./config.ini').absolute())
                          )
    testlist.add_argument('--suite',
                        type= lambda p: str(pathlib.Path(p).absolute()),
                        action='store',
                        help='The Path to the custom suite directory.',
                        metavar= 'PATH')
    return parser
