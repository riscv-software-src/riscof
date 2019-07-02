import os
import codecs
import pip
from setuptools import setup, find_packages

import riscof

# Base directory of package
here = os.path.abspath(os.path.dirname(__file__))


def read(*parts):
    with codecs.open(os.path.join(here, *parts), 'r') as fp:
        return fp.read()


#Long Description
with open("README.rst", "r") as fh:
    long_description = fh.read()

version = "1.4.3"

setup(name="riscof",
      version=version,
      description="RiscV Compliance Framework by Incoresemi Ltd.",
      long_description=long_description,
      classifiers=[
          "Programming Language :: Python :: 3.7",
          "License :: OSI Approved :: BSD-3-Clause",
          "Development Status :: 2 - Pre-Alpha"
      ],
      author='S Pawan Kumar',
      author_email='spawan1999@gmail.com',
      license='BSD-3-Clause',
      packages=find_packages(),
      package_dir={'riscof': 'riscof/'},
      package_data={
          'riscof': [
              'suite/env/*', 'suite/*.S', 'schemas/*',
              'framework/database.yaml', '../LICENSE'
          ]
      },
      install_requires=[
          'Cerberus>=1.3.1', 'GitPython>=2.1.11', 'oyaml>=0.9', 'PyYAML>=5.1.1'
      ],
      entry_points={
          "console_scripts": ["riscof=riscof.main:execute"],
      })
