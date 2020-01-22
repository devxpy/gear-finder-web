from distutils.core import setup

try:
    import numpy
    from Cython.Build import cythonize
except ImportError:
    ext_modules = None
    include_dirs = None
else:
    ext_modules = cythonize("gear_finder/compute.pyx", annotate=True)
    include_dirs = [numpy.get_include()]

setup(
    install_requires=[
        'django',
        'numpy',
        'scipy',
        'cython',
        'python-decouple',
        'gunicorn',
    ],
    name="Gear Finder Web",
    ext_modules=ext_modules,
    include_dirs=include_dirs,
)
