#!/usr/bin/env python
"""
browse to
http://localhost/latest.jpg

and put latest.jpg under dmcutils/static/
"""
from flask import Flask, send_from_directory
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import socket


# %%
app = Flask(__name__, static_url_path='')
limiter = Limiter(app,
                  # default_limits=["10/minute","1/second"],
                  global_limits=["10/minute", "1/second"],
                  key_func=get_remote_address)


@app.route('/')
def static_file():
    return send_from_directory(p.htmldir,
                               'latest.png',
                               as_attachment=False)


if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('port', help='port number', type=int)
    p.add_argument('htmldir', help='directory to serve files from')
    P = p.parse_args()

    try:
        app.run(host='0.0.0.0', port=P.port)
    except socket.error as e:
        raise RuntimeError(f'server may be already running  {e}')
