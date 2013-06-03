# -*- coding: utf-8 -*-

"""
    ldrawweb
    ~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import os

import yaml


DEFAULT_CONFIG_FILE = 'config.yml'


def update_config(filename=None):
    global config
    if filename is None:
        filename = os.getenv('LDRAWWEB_CONFIG_FILE') or \
            DEFAULT_CONFIG_FILE
    with open(filename) as f:
        config.clear()
        config.update(yaml.load(f.read()))


config = dict()
try:
    update_config()
except:
    pass
