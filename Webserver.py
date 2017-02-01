#!/usr/bin/env python
import logging
import socket
#
from flask import Flask, send_from_directory
from flask_limiter import Limiter

#%%
app = Flask(__name__)
limiter = Limiter(app,global_limits=["10/minute","1/second"])

@app.route('/')
def static_file():
    return send_from_directory('./html/',
                               'latest.png',
                               as_attachment=False)

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('port',help='port number',type=int)
    p = p.parse_args()

    try:
        app.run(host='0.0.0.0',port=p.port)
    except socket.error as e:
        logging.info('server may be already running  {}'.format(e))
