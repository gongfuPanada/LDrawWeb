# -*- coding: utf-8 -*-

"""
    ldrawweb.__main__
    ~~~~~~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import logging
import os.path
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import baker
from gevent.wsgi import WSGIServer

from ldrawweb import (config as config_, update_config,
                      DEFAULT_CONFIG_FILE)
from ldrawweb.app import Application


@baker.command(shortopts={'config': 'C',
                          'host': 'h',
                          'port': 'p'},
               params={'config': 'path to config file',
                       'port': 'port number',
                       'host': 'host address'})
def run(config=None, host='0.0.0.0', port=8080):
    try:
        update_config(config)
    except:
        logging.critical('config file %r not found!' %
                         (config or DEFAULT_CONFIG_FILE))
    # enable compression if run standalone
    from flask.ext.compress import Compress
    Compress(Application)
    Application.config['COMPRESS_DEBUG'] = True
    # basic logging confi
    if config_['debug']:
        logging.basicConfig(format=logging.DEBUG)
        # start debug server
        Application.run(debug=True, host=host, port=port)
    else:
        logging.basicConfig(format=logging.INFO)
        # start server
        server = WSGIServer((host, port), Application)
        server.serve_forever()


baker.run()
