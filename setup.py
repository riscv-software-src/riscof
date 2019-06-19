import os
import codecs
from setuptools import setup, find_packages

# Base directory of package
here = os.path.abspath(os.path.dirname(__file__))

def read(*parts):
    with codecs.open(os.path.join(here, *parts), 'r') as fp:
        return fp.read()

#Long Description

long_description = read('README.md')
version="1.2.0"

requirements=[
    'oyaml>=0.9',
    'Cerberus>=1.3.1',
    'GitPython>=2.1.11'
]

setup(
        name="riscof",
        version=version,
        description="RiscV Compliance Framework by Incoresemi Ltd.",
        long_description=long_description,
        classifiers=[
            "Programming Language :: Python :: 3.7",
        ],
        author='S Pawan Kumar',
        author_email='spawan1999@gmail.com',
        license='BSD',
        packages=find_packages(),
        entry_points={
            "console_scripts": [
                "riscof=riscof.main:execute",
            ],
        }
)
