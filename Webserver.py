#!/usr/bin/env python3
from __future__ import absolute_import
#
from flask import Flask, send_from_directory

#%%
app = Flask(__name__)

@app.route('/')
def static_file():
    return send_from_directory('./',
                               'latest.png',
                               as_attachment=False)

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('port',help='port number',type=int)
    p = p.parse_args()

    app.run(host='0.0.0.0',port=p.port)
