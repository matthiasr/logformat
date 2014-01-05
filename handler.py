#!/usr/bin/env python
from bottle import get, request, response, static_file, run
from logformat import chatlog, DirectoryListing
#from admin import admin_page, admin_post, auth
import time
import os

def getdirname(path):
    # FIXME: determine automatically
    return os.path.join('/srv/www/logs',path.lstrip('/'))

@get('<path:path>/css/<filename:path>')
def static_css(filename,path):
    return static_file(os.path.join('css',filename), root=os.path.dirname(__file__))

@get('<path:path>/')
@get('<path:path>/index.html')
def index(path):
    return str(DirectoryListing(getdirname(path), "de"))

@get('<path:path>/<basename>.txt')
def txt_log(basename,path):
    response.content_type = 'text/plain; charset=utf-8'
    response.set_header("Access-Control-Allow-Origin", '*')
    try:
        f = open(os.path.join(getdirname(path), basename+".log"))
        s = f.read()
        f.close()
        return str(chatlog(s,"de",plain=True))
    except IOError:
        response.status = 404
        return

@get('<path:path>/<basename>.html')
def html_log(basename,path):
    response.content_type = 'application/xhtml+xml; charset=utf-8'
    response.set_header("Access-Control-Allow-Origin", '*')
    try:
        f = open(os.path.join(getdirname(path), basename+".log"))
        s = f.read()
        f.close()
        return str(chatlog(s,"de",plain=False))
    except IOError:
        response.status = 404
        return

run()
