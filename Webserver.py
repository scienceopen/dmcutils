#!/usr/bin/env python3
from __future__ import absolute_import
#
from flask import Flask, send_from_directory

#%%
app = Flask(__name__)

@app.route('/')
def static_file():
    return send_from_directory('./',
                               'live.png',
                               as_attachment=False)

if __name__ == '__main__':
    app.run(host='0.0.0.0')