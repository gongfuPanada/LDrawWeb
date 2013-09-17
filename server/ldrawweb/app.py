# -*- coding: utf-8 -*-

"""
    ldrawweb.app
    ~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import json
import os

from flask import Flask, abort, make_response, render_template, request
from jinja2 import FileSystemLoader
from werkzeug.wrappers import Response

from ldrawweb import config, ROOT_PATH
from ldrawweb.ldraw import MIME_TYPE
from ldrawweb.local import query_local
from ldrawweb import util


__all__ = ['uri_for_dat', 'uri_for_mesh', 'Application']


DEFAULT_URI_PREFIX_DAT = '/geometry/dat/'
DEFAULT_URI_PREFIX_MESH = '/geometry/mesh/'


app = Flask(__name__, static_folder=os.path.join(ROOT_PATH, 'static'),
            static_url_path='/s',
            template_folder=os.path.join(ROOT_PATH, 'templates'))


def uri_for(prefix, path=None):
    if path is not None:
        return os.path.join(prefix, path)
    else:
        return prefix


def uri_for_dat(path=None):
    return uri_for(config['dat_uri_prefix'] or DEFAULT_URI_PREFIX_DAT, path)


def uri_for_mesh(path=None):
    return uri_for(config['mesh_uri_prefix'] or DEFAULT_URI_PREFIX_MESH, path)


def local_resource(path, basepath):
    print path, basepath
    if config['storage'] != 'local':
        abort(403)
    physpath = query_local(path, basepath)
    if physpath is None:
        abort(404)
    try:
        f = open(physpath)
    except IOError:
        abort(404)
    return Response(f, direct_passthrough=True, content_type=MIME_TYPE)


@app.route('/')
def index():
    raise NotImplemented


@app.route('/view')
def view():
    data = {}
    if 'uri' in request.args:
        data['uri'] = request.args.get('uri')
    else:
        raise NotImplemented
    response = make_response(render_template('view.html', **data))
    response.headers['Access-Control-Allow-Origin'] = '*'
    return response


@app.route(DEFAULT_URI_PREFIX_DAT + 'g/<path:path>')
def dat_global(path):
    return local_resource(path, config['dat_path'])


@app.route(DEFAULT_URI_PREFIX_MESH + 'g/<path:path>')
def mesh_global(path):
    return local_resource(path, config['mesh_path'])


@app.route(DEFAULT_URI_PREFIX_DAT + '<int:uid>/<string:name>')
def dat_user(uid, name):
    raise NotImplemented


@app.route(DEFAULT_URI_PREFIX_MESH + '<int:uid>/<string:name>')
def mesh_user(uid, name):
    raise NotImplemented


Application = app
