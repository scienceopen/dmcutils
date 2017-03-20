#!/usr/bin/env python
"""
browse to
http://localhost/latest.jpg

and put latest.jpg under dmcutils/static/
"""
import socket
from sys import stderr
#
from flask import Flask, send_from_directory
import flask_limiter

#%%
app = Flask(__name__,static_url_path='')
limiter = flask_limiter.Limiter(app,
                global_limits=["10/minute","1/second"],)
               # key_func=flask_limiter.util.get_ipaddr())

@app.route('/')
def static_file():
    return send_from_directory('static',
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
        print(f'server may be already running  {e}',file=stderr)
