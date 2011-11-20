# XXX broken and untested.
import os,sys

def getdirname():
    dirname = os.path.dirname(sys.argv[0])
    if dirname == '':
        dirname = '.'
    return dirname


authfile = os.path.join(getdirname(), ".htdigest")
realm = "#nodrama.de"

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

def get_users(fname,realm):
    return [u[0] for u in read_htdigest_file(fname) if u[1] == realm]

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

def create_user(fname,user,realm,digest_hash):
    users = read_htdigest_file(fname)
    for u in users:
        if u[0] == user and u[1] == realm:
            return False    # user exists
    f = open(fname,'a')
    f.write(':'.join((user,realm,digest_hash)) + "\n")
    f.close()
    return True

def admin_post(req):
    newpw = "niggurath"
    newuser = req.forms.get('newuser')
    if newuser != None:
        newuser = ''.join(c for c in newuser if c.islower())
        if len(newuser) < 3:
            note = "User name <em>" + newuser + "</em> is too short!"
        elif create_user(authfile,newuser,realm,htdigest(newuser,realm,newpw)):
            note = "Created new user <em>" + newuser + "</em> with password <em>" + newpw + "</em>"
        else:
            note = "User " + newuser + " already exists."
    else:
        oldpw = req.forms.getfirst('oldpw')
        newpw = req.forms.getfirst('newpw')
        newpw2 = req.forms.getfirst('newpw2')
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
    return admin_page(req,note)

def admin_page(user, url, note=""):
    print get_users(authfile,realm)
    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de">
    <head>
        <title>Change password</title>
    </head>
    <body>
        <h1>Change password for ''' + user + '''</h1>
        <p>''' + note + '''</p>
        <form name="pwchange" action="''' + url + '''" method="POST">
            Old: <input type="password" name="oldpw" /><br />
            New: <input type="password" name="newpw" /><br />
            Repeat: <input type="password" name="newpw2" /><br />
            <input type="submit" value="Change" />
        </form>
        <form name="createuser" action="''' + url + '''" method="POST">
            New user name: <input type="text" name="newuser" /><br />
            <input type="submit" value="Create user" />
        </form>
        <h2>Current users:</h2>
        <ul>
        <li>''' + '</li>\n<li>'.join(get_users(authfile,realm)) + '''</li>
        </ul>
    </body>
</html>'''

