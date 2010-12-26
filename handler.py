from mod_python import apache
from stats import DirectoryStatistics
from logformat import chatlog, DirectoryListing
import time
import os

def check_basename(n):
    try:
        time.strptime(n,"%Y-%m-%d")
        return True
    except ValueError:
        return False

def handler(req):
    formats = { 'svg': 'image/svg+xml',
            'png': 'image/png',
            'json': 'application/json',
            'txt':'text/plain; charset=utf-8',
            'html':'application/xhtml+xml; charset=utf-8' }
    basename, ext = os.path.splitext(os.path.basename(req.filename))
    ext = ext[1:]
    dirname = os.path.dirname(req.filename)

    if not ext in formats:
        return apache.DECLINED

    req.content_type = formats[ext]
    req.headers_out["Access-Control-Allow-Origin"] = '*'

    if basename == "stats" and ext != "html":
        if ext == "json":
            req.write(str(DirectoryStatistics(dirname,json=True)))
            return apache.OK
        elif ext == 'txt':
            req.write(str(DirectoryStatistics(dirname,json=False)))
            return apache.OK
        else:
            req.write(DirectoryStatistics(dirname,json=False).graph(ext))
            return apache.OK
    elif check_basename(basename):
        if ext == 'txt':
            plain = True
        elif ext == 'html':
            plain = False
        else:
            return apache.HTTP_NOT_FOUND
        req.content_type = formats[ext]
        try:
            f = open(os.path.join(dirname, basename+".log"))
        except IOError:
            return apache.HTTP_NOT_FOUND
        req.write(str(chatlog(f.read(),"de",plain=plain)))
        f.close()
        return apache.OK
    elif basename == "index" and ext == "html":
        req.write(str(DirectoryListing(dirname, "de")))
        return apache.OK
    else:
        return apache.DECLINED
