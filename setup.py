from distutils.core import setup
from distutils.extension import Extension

ext_modules = [
    Extension(name='foma',
        sources=['python/foma.c'],
        language='C++', 
        include_dirs=['foma'],
        library_dirs=['foma'],
        libraries=['z', 'foma'], 
        extra_compile_args=['-O3'],
        extra_link_args=['-Wl,-rpath,foma'])
]

setup(
    name='kenlm',
    ext_modules=ext_modules
)
