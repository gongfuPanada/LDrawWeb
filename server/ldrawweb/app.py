# -*- coding: utf-8 -*-

"""
    ldrawweb.app
    ~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import json
import os

from flask import Flask, abort, make_response, render_template, request, \
                  send_file
from jinja2 import FileSystemLoader
from werkzeug.wrappers import Response
import requests

from ldrawweb import config, ROOT_PATH
from ldrawweb.ldraw import LDRAW_MIME_TYPE
from ldrawweb.local import query_local
from ldrawweb import util


__all__ = ['uri_for_dat', 'uri_for_mesh', 'Application']


app = Flask(__name__, static_folder=os.path.join(ROOT_PATH, 'static'),
            static_url_path='/s',
            template_folder=os.path.join(ROOT_PATH, 'templates'))


def uri_for(prefix, path=None):
    if path is not None:
        return os.path.join(prefix, path)
    else:
        return prefix


def uri_for_dat(path=None):
    return uri_for('/geometry/dat', path)


def uri_for_mesh(path=None):
    return uri_for('/geometry/postprocessed', path)


@app.route('/')
def index():
    raise NotImplemented


@app.route('/view', methods=['GET', 'POST'])
def view():
    data = {}
    if 'file' in request.files:
        f = request.files['file']
        data['model'] = f.read()
        f.close()
    else:
        if 'uri' in request.args:
            uri = request.args.get('uri')
            if uri.startswith('http://') or uri.startswith('https://'):
                data['model'] = requests.get(uri).content.decode('utf-8', 'IGNORE')
            data['uri'] = request.args.get('uri')
        else:
            raise NotImplemented
    response = make_response(render_template('view.html', **data))
    response.headers['Access-Control-Allow-Origin'] = '*'
    return response


@app.route('/geometry/dat/g/<path:path>')
def dat_global(path):
    if config['storage'] != 'local':
        abort(403)
    physpath = query_local(path, config['dat_path'])
    if physpath is None:
        abort(404)
    return send_file(physpath, mimetype=LDRAW_MIME_TYPE)


@app.route('/geometry/postprocessed/g/<path:path>')
def mesh_global(path):
    if config['storage'] != 'local':
        abort(403)
    physpath = query_local(path, config['mesh_path'])
    if physpath is None:
        abort(404)
    return send_file(physpath, mimetype='application/json')


@app.route('/geometry/dat/<int:uid>/<string:name>')
def dat_user(uid, name):
    raise NotImplemented


@app.route('/geometry/postprocessed/<int:uid>/<string:name>')
def mesh_user(uid, name):
    raise NotImplemented


Application = app
