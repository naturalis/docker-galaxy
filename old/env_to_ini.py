## to be compatible with python 3
from __future__ import print_function
from os import environ
from sys import argv, exit

IDENT = '__'
SEP = '='
PASS = ['[','#',';']

if len(argv) != 3:
    print('ERROR: got invalid arguments. Got this: %s' % argv)
    print('Usage: python env_to_ini.py <ini_template_file> <output-file>')
    exit(1)

with open(argv[1]) as f:
    for l in f.readlines():
        l = l.strip()
        if not any(l.startswith(s) for s in PASS):
            k,v = l.split(SEP)
            if v.strip().startswith(IDENT):
                try:
                    v = environ[v[len(IDENT)+1:]]
                except:
                    print('ERROR unable to get ENV : %s' % v[len(IDENT)+1:])
                    exit(1)
            l = '%s %s %s' % (k.strip(),SEP,v.strip())
        with open(argv[2], 'a') as o:
            o.write("%s\n" % l)
