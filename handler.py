#!/usr/bin/env python
from bottle import get, request, response, static_file, run
from logformat import chatlog, DirectoryListing
#from admin import admin_page, admin_post, auth
import time
import os

def getdirname():
    dirname = os.path.dirname(__file__)
    if dirname == '':
        dirname = '.'
    return dirname

@get('/css/<filename:path>')
def static_css(filename):
    return static_file(os.path.join('css',filename), root=getdirname())

@get('/')
@get('/index.html')
def index():
    return str(DirectoryListing(getdirname(), "de"))

@get('/<basename>.txt')
def txt_log(basename):
    response.content_type = 'text/plain; charset=utf-8'
    response.set_header("Access-Control-Allow-Origin", '*')
    try:
        f = open(os.path.join(getdirname(), basename+".log"))
        s = f.read()
        f.close()
        return str(chatlog(s,"de",plain=True))
    except IOError:
        response.status = 404
        return

@get('/<basename>.html')
def html_log(basename):
    response.content_type = 'application/xhtml+xml; charset=utf-8'
    response.set_header("Access-Control-Allow-Origin", '*')
    try:
        f = open(os.path.join(getdirname(), basename+".log"))
        s = f.read()
        f.close()
        return str(chatlog(s,"de",plain=False))
    except IOError:
        response.status = 404
        return

run(port=8000)
