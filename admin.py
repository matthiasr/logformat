from mod_python import apache, util
import os

# HTTP Digest computation
# from http://trac.edgewall.org/wiki/TracStandalone
try:
        from hashlib import md5
except ImportError:
        from md5 import md5
def htdigest(user,realm,password):
    return md5(':'.join((user,realm,password))).hexdigest()

def read_htdigest_file(fname):
    f = open(fname,'r')     # XXX handle errors
    users = []
    for line in f:
        line = line.strip()
        users.append(line.split(':'))        # XXX handle empty / comment lines
    f.close()
    return users

def get_hash(fname,user,realm):
    users = read_htdigest_file(fname)
    for u in users:
        if u[0] == user and u[1] == realm:
            return u[2]
    return None

def set_hash(fname,user,realm,digest_hash):
    users = read_htdigest_file(fname)
    f = open(fname,'w')                     # XXX subject to race conditions
    for u in users:
        if u[0] == user and u[1] == realm:
            u[2] = digest_hash
        f.write(':'.join(u) + "\n")
    f.close()


def UserAdmin(req):
    authfile = os.path.join(os.path.dirname(req.filename), ".htdigest")
    realm = "#nodrama.de"
    if req.method == "POST":
        form = util.FieldStorage(req)
        oldpw = form.getfirst('oldpw')
        newpw = form.getfirst('newpw')
        newpw2 = form.getfirst('newpw2')
        if oldpw == None:
            note = "Please enter your old password!"
        elif htdigest(req.user,realm,oldpw) != get_hash(authfile,req.user,realm):
            note = "Incorrect password"
        elif newpw == None:
            note = "No new password supplied!"
        elif newpw != newpw2:
            note = "New passwords don't match!"
        else:
            set_hash(authfile,req.user,realm,htdigest(req.user,realm,newpw))
            note = "Password updated"
    else:
        note = ""

    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de">
    <head>
        <title>Change password</title>
    </head>
    <body>
        <h1>Change password for ''' + req.user + '''</h1>
        <p>''' + note + '''</p>
        <form name="pwchange" action="''' + req.uri + '''" method="POST">
            Old: <input type="password" name="oldpw" /><br />
            New: <input type="password" name="newpw" /><br />
            Repeat: <input type="password" name="newpw2" /><br />
            <input type="submit" value="Change" />
        </form>
    </body>
</html>'''
