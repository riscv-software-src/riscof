import os
import codecs
import pip
from setuptools import setup, find_packages

# Base directory of package
here = os.path.abspath(os.path.dirname(__file__))


def read(*parts):
    with codecs.open(os.path.join(here, *parts), 'r') as fp:
        return fp.read()
def read_requires():
    with open(os.path.join(here, "riscof/requirements.txt"),"r") as reqfile:
        return reqfile.read().splitlines()


#Long Description
with open("README.rst", "r") as fh:
    readme = fh.read()
setup_requirements = [ ]

test_requirements = [ ]

setup(name="riscof",
      version='1.25.2',
      description="RISC-V Architectural Test Framework",
      long_description=readme + '\n\n',
      classifiers=[
          "Programming Language :: Python :: 3.6",
          "License :: OSI Approved :: BSD License",
          "Development Status :: 4 - Beta"
      ],
      url='https://github.com/riscv/riscof',
      author='InCore Semiconductors Pvt. Ltd.',
      author_email='neelgala@incoresemi.com',
      license='BSD-3-Clause',
      packages=find_packages(),
      package_dir={'riscof': 'riscof/'},
      package_data={
          'riscof': [
              'requirements.txt',
              'Templates/coverage.html',
              'framework/database.yaml',
              'Templates/report.html',
              'Templates/style.css',
              'Templates/setup/*',
              'Templates/setup/model/env/*',
              'Templates/setup/model/*',
              'Templates/setup/sail_cSim/*',
              'Templates/setup/sail_cSim/env/*',
              'Templates/setup/reference/*',
              'Templates/setup/reference/env/*'
          ]
      },
      install_requires=read_requires(),
      python_requires=">=3.6.0",
      entry_points={
          "console_scripts": ["riscof=riscof.cli:cli"],
      },
    include_package_data=True,
    keywords='riscof',
    test_suite='',
    tests_require=test_requirements,
    zip_safe=False,)
