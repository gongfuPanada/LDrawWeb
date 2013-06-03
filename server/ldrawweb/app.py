# -*- coding: utf-8 -*-

"""
    ldrawweb.app
    ~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import os

from flask import Flask

from ldrawweb import config


__all__ = ['Application']


app = Flask(__name__)


@app.route('/')
def index():
    return 'hello world %s' % config['debug']


@app.route('/geometry/dat/<path:entry>')
def dat(entry):
    entry = entry.lower()


@app.route('/geometry/processed/<path:entry>')
def processed(entry):
    return 'not implemented'


Application = app
