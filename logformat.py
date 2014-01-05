#!/usr/bin/python
# -*- coding: utf-8 -*-

#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 3 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

from sys import argv
import re
import time
import locale
import os

try:
    from mod_python import apache
except:
    pass

class chatlog:
    def __init__(self, textlog, language, plain=False):
        """
        Input a text/plain chatlog from zweipktfkt and get out HTML5 goodness.
        """

        # precompile regular expressions
        chars_re = re.compile(u'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]')
        uri_patterns = [ r'''((?<=\()\b[A-Za-z][A-Za-z0-9\+\.\-]*:([A-Za-z0-9\.\-_~:/\?#\[\]@!\$&'\(\)\*\+,;=]|%[A-Fa-f0-9]{2})+(?=\)))''', r'''((?<=&lt;)\b[A-Za-z][A-Za-z0-9\+\.\-]*:([A-Za-z0-9\.\-_~:/\?#\[\]@!\$&'\(\)\*\+,;=]|%[A-Fa-f0-9]{2})+(?=&gt;))''', r'''(?<!\()\b([A-Za-z][A-Za-z0-9\+\.\-]*:([A-Za-z0-9\.\-_~:/\?#\[\]@!\$&'\(\)\*\+,;=]|%[A-Fa-f0-9]{2})+)''', ]
        uri_res = [re.compile(p) for p in uri_patterns]

        self.log = ""

        firstline = textlog.split("\n")[0]
        try:
            locale.setlocale(locale.LC_ALL, "en_US.UTF-8")
            datetime = time.strptime(firstline[15:])
        except ValueError:
            locale.setlocale(locale.LC_ALL, "de_DE.UTF-8")
            datetime = time.strptime(firstline[15:])
        locale.setlocale(locale.LC_ALL, "de_DE.UTF-8")

        if not plain:
            self.log += '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="''' + language + '''">
<head>
    <title>Log für ''' + time.strftime("%A, den %d. %B %Y", datetime) + '''</title>
    <link rel="stylesheet" href="css/tango.css" title="Defaul-Stil" type="text/css"/>
</head>
<body>
<a class="plaintextlink" href="''' + time.strftime("%Y-%m-%d",datetime)+".txt" + '''">Plaintext</a><br />
<label for="compact">
    <input type="checkbox" id="compact" onclick="save()"/> Compact
</label>
<script><![CDATA[
    document.addEventListener("DOMContentLoaded", restore, false);

    function restore() {
        var checkbox = document.getElementById('compact');
        var storage = localStorage;
        if (storage.getItem('compacted') == 'true') {
            checkbox.checked = 'true';
            }
        showhide();
    }

    function save() {
        var checkbox = document.getElementById('compact');
        var storage = localStorage;
        storage.setItem('compacted', checkbox.checked)
        showhide();
    }

    function showhide() {
        var checkbox = document.getElementById('compact');
        var head = document.getElementsByTagName("head")[0];

        // not using localStorage here, so this also works in older browsers
        if (checkbox.checked) {
            // hide non-dialog lines
            var style = document.createElement('style');
            style.id = 'compact-css';
            style.textContent = '.non-dialog, .non-dialog + br { display: none; }';

            head.appendChild(style);
        } else {
            // show non-dialog lines
            var style = document.getElementById('compact-css');

            head.removeChild(style);
        }
    }
]]></script>
<!-- link to last line -->'''

        lastlineid = 1

        for lineid, line in enumerate(textlog.split("\n")):

            # remove erroneous spaces
            try:
                if line[6:8] == "< ":
                    line = line[:7] + line[8:]
            except IndexError:
                pass

            # replace xml chars
            if not plain:
                line = line.replace("&","&amp;")
                line = line.replace("<","&lt;")
                line = line.replace(">","&gt;")
                line = line.replace("'","&apos;")
                line = line.replace("\"","&quot;")

            # input is mixed utf-8 and latin-1
            try:
                line = unicode(line,'utf-8','strict')
            except UnicodeDecodeError:
                line = unicode(line,'latin-1','strict')

            line = line.encode('utf-8')
            if not plain:
                # WTF is this supposed to do?
                line, count = chars_re.subn('',line)

            if not plain:
                # markup log time, add anchors, mark non-speak lines
                try:
                    int(line[:2])
                    int(line[3:5])
                    line = '<span class="time">' + line[:5] + '</span>' + line[5:]
        
                    if line[32:36] == "&lt;":
                        line = '<a class="line-marker" href="#' + str(lineid) + '">#</a><span class="line dialog" id="' + str(lineid) + '">' + line + '</span>'
                    else:
                        line = '<a class="line-marker non-dialog" href="#' + str(lineid) + '">#</a><span class="line non-dialog" id="' + str(lineid) + '">' + line + '</span>'

                    lastlineid = lineid
                except ValueError:
                    pass

                # markup links
                uri_replacement = r'''<a href="\1">\1</a>'''

                for p in uri_res:
                    line, nsubs = p.subn(uri_replacement, line)
                    if nsubs > 0: break     # only use first matching pattern

            self.log += line + ("\n" if plain else "<br/>\n")

            if (not plain) and line == textlog.split("\n")[-1:][0]:
                link = '''<a class="line-link" id="1" href="#''' + str(lastlineid) + '''">⤓</a>'''
                self.log = self.log.replace("<!-- link to last line -->", link)

        if not plain:
            self.log += """</body>
</html>"""

    def __str__(self):
        return self.log

class DirectoryListing:
    def __init__(self, path, language):
        self.listing = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="''' + language + '''">
<head>
    <title>Logs</title>
    <link rel="stylesheet" href="css/tango.css" title="Defaul-Stil" type="text/css"/>
</head>
<body>
'''

        files = [l for l in os.listdir(path) if l[-4:] == ".log"]
        files.sort()
        files.reverse()
        for f in files:
            self.listing += "<a href=\"" + os.path.splitext(f)[0]+".html" + "\">" + f[:-4] + "</a>"
            self.listing += " (<a href=\"" + os.path.splitext(f)[0]+".txt"  + "\">plain</a>)"
            self.listing += "<br />\n"

        #self.listing += """<p><a href="admin.html">Change password</a></p></body>
        self.listing += """</body>
</html>"""

    def __str__(self):
        return self.listing


if __name__ == '__main__':
    infile = argv[1]
    if os.path.isdir(infile):
        outfile = os.path.join(infile, "index.html")
        g = open(outfile,"w")
        g.write(str(DirectoryListing(infile, "de")))
        g.close()
    else:
        outfile = infile + ".xhtml"

        f = open(infile, "r")
        input = f.read()
        f.close()

        nicelog = str(chatlog(input, "de"))
        stats = DirectoryStatistics.FileStatistics(input)
        print str(stats)

        g = open(outfile, "w")
        g.write(nicelog)
        g.close()

