# -*- coding: utf-8 -*-

"""
    ldrawweb.app
    ~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import json
import os

from flask import Flask, abort, render_template, request
from jinja2 import FileSystemLoader
from werkzeug.wrappers import Response

from ldrawweb import config, ROOT_PATH
from ldrawweb.ldraw import MIME_TYPE
from ldrawweb import util


__all__ = ['Application']


DEFAULT_URI_PREFIX_DAT = '/geometry/dat/'
DEFAULT_URI_PREFIX_MESH = '/geometry/mesh/'


app = Flask(__name__, static_folder=os.path.join(ROOT_PATH, 'static'),
            static_url_path='/s',
            template_folder=os.path.join(ROOT_PATH, 'templates'))


def uri_for_dat(path=None):
    if config['dat_uri_prefix'] is None:
        prefix = DEFAULT_URI_PREFIX_DAT
    else:
        prefix = config['dat_uri_prefix']
    if path is not None:
        if not prefix.endswith('/'):
            prefix += '/'
        return '%s%s' % (prefix, path)
    else:
        return prefix


def uri_for_mesh(path=None):
    if config['mesh_uri_prefix'] is None:
        prefix = DEFAULT_URI_PREFIX_MESH
    else:
        prefix = config['mesh_uri_prefix']
    if path is not None:
        if not prefix.endswith('/'):
            prefix += '/'
        return '%s%s' % (prefix, path)
    else:
        return prefix


@app.route('/')
def index():
    return 'hello world %s' % config['debug']


@app.route('/view')
def view():
    data = {}
    if 'uri' in request.args:
        data['uri'] = request.args.get('uri')
    else:
        data['model'] = json.dumps({'hello': 'world', 2: 3, 'foo': [1, 2, 3]})
    return render_template('view.html', **data)


@app.route(DEFAULT_URI_PREFIX_DAT + 'g/<path:path>')
def dat_global(path):
    if config['storage'] != 'local':
        abort(403)
    physpath = config['dat_path'] + '/' + util.normalize_path(path)
    try:
        f = open(physpath)
    except IOError:
        abort(404)
    return Response(f, direct_passthrough=True, content_type=MIME_TYPE)


@app.route(DEFAULT_URI_PREFIX_MESH + 'g/<path:path>')
def mesh_global(path):
    if config['storage'] != 'local':
        abort(403)
    physpath = config['mesh_path'] + '/' + util.normalize_path(path)
    try:
        f = open(physpath)
    except IOError:
        abort(404)
    return Response(f, direct_passthrough=True, content_type='application/json')


Application = app
