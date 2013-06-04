# -*- coding: utf-8 -*-

"""
    ldrawweb
    ~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import os
from UserDict import UserDict

import yaml


DEFAULT_CONFIG_FILE = 'config.yml'
ROOT_PATH = os.path.join(os.path.dirname(__file__), '..')


def update_config(filename=None):
    """Read config file"""
    global config
    if filename is None:
        filename = os.getenv('LDRAWWEB_CONFIG_FILE') or \
            DEFAULT_CONFIG_FILE
    with open(filename) as f:
        config.clear()
        config.update(yaml.load(f.read()))


class ConfigDict(UserDict):
    def __getitem__(self, key):
        # return None rather than generating exception
        if not key in self:
            return None
        return UserDict.__getitem__(self, key)


config = ConfigDict()
try:
    # try to load the default config
    # reload later when calling __main__ explicitly
    update_config()
except:
    pass
