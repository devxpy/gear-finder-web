from distutils.core import setup

import numpy
from Cython.Build import cythonize

setup(
    name="Hello world app",
    ext_modules=cythonize("gear_finder/compute.pyx", annotate=True),
    include_dirs=[numpy.get_include()]
)