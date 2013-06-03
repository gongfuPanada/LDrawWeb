# -*- coding: utf-8 -*-

"""
    ldrawweb.__main__
    ~~~~~~~~~~~~~~~~~

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

import logging
import sys

import baker
from gevent.wsgi import WSGIServer

from ldrawweb import (config as config_, update_config,
                      DEFAULT_CONFIG_FILE)
from ldrawweb.app import Application


@baker.command(params={'config': 'path to config file',
                       'port': 'port number',
                       'host': 'host address'})
def run(config=None, host='127.0.0.1', port=8080):
    try:
        update_config(config)
    except:
        logging.critical('config file %r not found!' %
                         (config or DEFAULT_CONFIG_FILE))
    # basic logging config
    if config_['debug']:
        Application.debug = True
        logging.basicConfig(format=logging.DEBUG)
    else:
        logging.basicConfig(format=logging.INFO)
    # start server
    server = WSGIServer((host, port), Application)
    server.serve_forever()


baker.run()
