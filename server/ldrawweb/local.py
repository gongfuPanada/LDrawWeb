# -*- coding: utf-8 -*-

"""
    ldrawweb.local
    ~~~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import os.path

from ldrawweb.util import normalize_path


def query_local(path, basepath):
    path = normalize_path(path)
    if path.startswith('p/') or path.startswith('parts/'):
        realpath = os.path.join(basepath, path)
        if os.path.exists(realpath):
            return realpath
        else:
            return None
    else:
        # search for parts/
        realpath = os.path.join(basepath, 'parts', path)
        if os.path.exists(realpath):
            return realpath
        # search for p/
        realpath = os.path.join(basepath, 'p', path)
        if os.path.exists(realpath):
            return realpath
        return None
    
