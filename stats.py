from mod_python import apache
from datetime import datetime
import time
import os
import locale

from matplotlib.figure import Figure
from matplotlib.backends.backend_agg import FigureCanvasAgg
from matplotlib.dates import MonthLocator, DateFormatter, date2num
from cStringIO import StringIO

class DirectoryStatistics:
    class FileStatistics:
        nondialoglines = 0
        dialoglines = 0
        datetime = None
        json = False

        def __init__(self, textlog, json=False):
            self.json = json
            firstline = textlog.split("\n")[0]
            try:
                locale.setlocale(locale.LC_ALL, "en_US.utf-8")
                self.datetime = (time.strptime(firstline[15:]))
            except ValueError:
                locale.setlocale(locale.LC_ALL, "de_DE.utf-8")
                self.datetime = (time.strptime(firstline[15:]))
            locale.setlocale(locale.LC_ALL, "de_DE.utf-8")

            for line in textlog.split("\n"):
                try:
                    if line[6] == '<':
                        self.dialoglines += 1
                    else:
                        self.nondialoglines += 1
                except IndexError:
                    pass

        def __str__(self):
            if self.json:
                return "{ \"date\":\"" + time.strftime("%Y-%m-%d", self.datetime) \
                        + "\", \"dialog\":" + str(self.dialoglines) \
                        + ", \"non-dialog\":" + str(self.nondialoglines)  + " }"
            else:
                return time.strftime("%Y-%m-%d", self.datetime) + "\t" + str(self.dialoglines) \
                        + "\t" + str(self.nondialoglines)

    def __init__(self, path, json=False):
        self.__l = []
        self.json = json
        files = [l for l in os.listdir(path) if l[-4:] == ".log"]
        files.sort()
        for infile in files:
            f = open(os.path.join(path,infile), "r")
            input = f.read()
            f.close()
            self.__l.append(self.FileStatistics(input,json))

    def __getitem__(self,key):
        return self.__l[key]

    def __len__(self):
        return len(self.__l)

    def __iter__(self):
        return iter(self.__l)

    def __str__(self):
        result = "[\n" if self.json else ""
        for stat in self:
            result += str(stat) + (", \n" if self.json else "\n")
        if self.json: result = result[:-3] + "\n]\n"
        return result

    def graph(self, ext="svg"):
        dates = [datetime.strptime(time.strftime("%Y-%m-%d", s.datetime),"%Y-%m-%d") for s in self]
        dialog = [s.dialoglines for s in self]
        total = [s.nondialoglines+s.dialoglines for s in self]

        fig = Figure(figsize=(8,6))
        ax = fig.add_subplot(1,1,1)

        ax.plot_date(dates, total, linestyle='-', marker='', linewidth=0.5, color='black', label="Gesamt")
        ax.plot_date(dates, dialog, linestyle='--', marker='', linewidth=0.5, color='black', label="Dialog")

        ax.xaxis.set_major_locator(MonthLocator())
        ax.xaxis.set_major_formatter(DateFormatter("%Y-%m"))
        fig.autofmt_xdate()
        ax.legend(prop={'size':'small'},loc=0)
        ax.autoscale_view()

        outf = StringIO()
        canvas = FigureCanvasAgg(fig)
        canvas.print_figure(outf,format=ext,dpi=300)
        result = outf.getvalue()
        outf.close()
        return result
