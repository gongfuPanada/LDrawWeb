# -*- coding: utf-8 -*-

"""
    ldrawweb.util
    ~~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

def normalize_path(path):
    return path.lower().replace('\\', '/')


def str2int(val):
    if isinstance(val, basestring) and val.startswith('0x'):
        return int(val, 16)
    return int(val)
