#!/usr/bin/env python3
import os, re
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, chr(108)+chr(105)+chr(98))
PN = {}
CN = {}
def scan():
    items = {}
    for d in [LIB, os.path.join(LIB,chr(118)+chr(105)+chr(101)+chr(119)+chr(101)+chr(114)+chr(115)), os.path.join(LIB,chr(115)+chr(101)+chr(114)+chr(118)+chr(105)+chr(99)+chr(101)+chr(115)), os.path.join(LIB,chr(119)+chr(105)+chr(100)+chr(103)+chr(101)+chr(116)+chr(115))]:
        if not os.path.isdir(d): continue
        for f in sorted(os.listdir(d)):
            if not f.endswith(chr(46)+chr(100)+chr(97)+chr(114)+chr(116)) or chr(108)+chr(49)+chr(48)+chr(110) in f or chr(103)+chr(101)+chr(110)+chr(101)+chr(114)+chr(97)+chr(116)+chr(101)+chr(100) in f: continue
            with open(os.path.join(d,f)) as fh:
                for i,l in enumerate(fh,1):
                    if chr(84)+chr(46)+chr(115)+chr(116)+chr(121)+chr(108)+chr(101) not in l: continue
                    m = re.search(chr(114)+chr(34)+chr(84)+chr(92)+chr(46)+chr(115)+chr(116)+chr(121)+chr(108)+chr(101), l)