#!/usr/bin/python

# on ubuntu 12.4 LTS:
# sudo apt-get install python-markdown
# sudo pip install --upgrade pygments

import os
import sys
import markdown
import markdown.preprocessors
import markdown.extensions
import re

style_decl = """<style><!--
.codehilite .hll { background-color: #ffffcc }
.codehilite  { background: #f0f0f0; margin-left: 3em; margin-right: 3em; }
.codehilite .c { color: #408080; font-style: italic } /* Comment */
.codehilite .err { border: 1px solid #FF0000 } /* Error */
.codehilite .k { color: #008000; font-weight: bold } /* Keyword */
.codehilite .o { color: #666666 } /* Operator */
.codehilite .cm { color: #408080; font-style: italic } /* Comment.Multiline */
.codehilite .cp { color: #BC7A00 } /* Comment.Preproc */
.codehilite .c1 { color: #408080; font-style: italic } /* Comment.Single */
.codehilite .cs { color: #408080; font-style: italic } /* Comment.Special */
.codehilite .gd { color: #A00000 } /* Generic.Deleted */
.codehilite .ge { font-style: italic } /* Generic.Emph */
.codehilite .gr { color: #FF0000 } /* Generic.Error */
.codehilite .gh { color: #000080; font-weight: bold } /* Generic.Heading */
.codehilite .gi { color: #00A000 } /* Generic.Inserted */
.codehilite .go { color: #808080 } /* Generic.Output */
.codehilite .gp { color: #000080; font-weight: bold } /* Generic.Prompt */
.codehilite .gs { font-weight: bold } /* Generic.Strong */
.codehilite .gu { color: #800080; font-weight: bold } /* Generic.Subheading */
.codehilite .gt { color: #0040D0 } /* Generic.Traceback */
.codehilite .kc { color: #008000; font-weight: bold } /* Keyword.Constant */
.codehilite .kd { color: #008000; font-weight: bold } /* Keyword.Declaration */
.codehilite .kn { color: #008000; font-weight: bold } /* Keyword.Namespace */
.codehilite .kp { color: #008000 } /* Keyword.Pseudo */
.codehilite .kr { color: #008000; font-weight: bold } /* Keyword.Reserved */
.codehilite .kt { color: #B00040 } /* Keyword.Type */
.codehilite .m { color: #666666 } /* Literal.Number */
.codehilite .s { color: #BA2121 } /* Literal.String */
.codehilite .na { color: #7D9029 } /* Name.Attribute */
.codehilite .nb { color: #008000 } /* Name.Builtin */
.codehilite .nc { color: #0000FF; font-weight: bold } /* Name.Class */
.codehilite .no { color: #880000 } /* Name.Constant */
.codehilite .nd { color: #AA22FF } /* Name.Decorator */
.codehilite .ni { color: #999999; font-weight: bold } /* Name.Entity */
.codehilite .ne { color: #D2413A; font-weight: bold } /* Name.Exception */
.codehilite .nf { color: #0000FF } /* Name.Function */
.codehilite .nl { color: #A0A000 } /* Name.Label */
.codehilite .nn { color: #0000FF; font-weight: bold } /* Name.Namespace */
.codehilite .nt { color: #008000; font-weight: bold } /* Name.Tag */
.codehilite .nv { color: #19177C } /* Name.Variable */
.codehilite .ow { color: #AA22FF; font-weight: bold } /* Operator.Word */
.codehilite .w { color: #bbbbbb } /* Text.Whitespace */
.codehilite .mf { color: #666666 } /* Literal.Number.Float */
.codehilite .mh { color: #666666 } /* Literal.Number.Hex */
.codehilite .mi { color: #666666 } /* Literal.Number.Integer */
.codehilite .mo { color: #666666 } /* Literal.Number.Oct */
.codehilite .sb { color: #BA2121 } /* Literal.String.Backtick */
.codehilite .sc { color: #BA2121 } /* Literal.String.Char */
.codehilite .sd { color: #BA2121; font-style: italic } /* Literal.String.Doc */
.codehilite .s2 { color: #BA2121 } /* Literal.String.Double */
.codehilite .se { color: #BB6622; font-weight: bold } /* Literal.String.Escape */
.codehilite .sh { color: #BA2121 } /* Literal.String.Heredoc */
.codehilite .si { color: #BB6688; font-weight: bold } /* Literal.String.Interpol */
.codehilite .sx { color: #008000 } /* Literal.String.Other */
.codehilite .sr { color: #BB6688 } /* Literal.String.Regex */
.codehilite .s1 { color: #BA2121 } /* Literal.String.Single */
.codehilite .ss { color: #19177C } /* Literal.String.Symbol */
.codehilite .bp { color: #008000 } /* Name.Builtin.Pseudo */
.codehilite .vc { color: #19177C } /* Name.Variable.Class */
.codehilite .vg { color: #19177C } /* Name.Variable.Global */
.codehilite .vi { color: #19177C } /* Name.Variable.Instance */
.codehilite .il { color: #666666 } /* Literal.Number.Integer.Long */
.state { background: #333; color: #fff; margin-left: 1em; margin-right: 1em; padding: 4px; padding-left: 1em; }
a { text-decoration: none; }
--></style>"""

# globqal state variables (hack! hack!)
last_found_title = ""
last_found_state = ""
last_found_version = ""

class VlogHammerExtension(markdown.extensions.Extension):

    class OpenClosedPreprocessor(markdown.preprocessors.Preprocessor):
        def run(self, lines):
            global last_found_state
            global last_found_version
            new_lines = []
            for line in lines:
                m = re.match(r'^~OPEN~\s*(.*)', line)
                if m:
                    last_found_state = "OPEN"
                    last_found_version = m.group(1)
                    new_lines.append('<div class="state"><strong>OPEN:</strong> last verified in <strong>%s</strong></div>' % m.group(1));
                    continue
                m = re.match(r'^~WONTFIX~\s*(.*)', line)
                if m:
                    last_found_state = "WONTFIX"
                    last_found_version = m.group(1)
                    new_lines.append('<div class="state"><strong>WONTFIX:</strong> last verified in <strong>%s</strong>, vendor said he would not fix it</div>' % m.group(1));
                    continue
                m = re.match(r'^~CLOSED~\s*(.*)', line)
                if m:
                    last_found_state = "CLOSED"
                    last_found_version = m.group(1)
                    new_lines.append('<div class="state"><strong>CLOSED:</strong> fixed in <strong>%s</strong></div>' % m.group(1));
                    continue
                new_lines.append(line)
            return new_lines

    class TitleFinderPreprocessor(markdown.preprocessors.Preprocessor):
        def run(self, lines):
            global last_found_title
            last_line = ''
            for line in lines:
                if re.match(r'^=+$', line):
                    last_found_title = last_line
                last_line = line
            return lines

    def extendMarkdown(self, md, md_globals):
        md.preprocessors.add('OpenClosed', self.OpenClosedPreprocessor(md), '_begin')
        md.preprocessors.add('TitleFinder', self.TitleFinderPreprocessor(md), '_begin')
        pass

input_dir = sys.argv[1]
output_dir = sys.argv[2]

open_bugs = {}
wontfix_bugs = {}
closed_bugs = {}

for filename in os.listdir(input_dir):
    basename = re.sub(r'\.md$', '', filename)
    if basename != filename:
        print("Processing %s.." % filename)
        f = open(input_dir + '/' + filename)
        md_html = markdown.markdown(''.join(f), extensions=['codehilite', VlogHammerExtension()])
        f.close()

        bug = '<tr><td valign="top"><a href="vloghammer_bugs/%s.html">%s</a></td><td valign="top">%s</td><td valign="top">%s</td></tr>\n' % (basename, basename, last_found_version, last_found_title)
        if last_found_state == "OPEN":
            open_bugs[basename] = bug
        if last_found_state == "WONTFIX":
            wontfix_bugs[basename] = bug
        if last_found_state == "CLOSED":
            closed_bugs[basename] = bug

        f = open(output_dir + '/' + basename + '.html', 'w')
        f.write('<html><head><title>VlogHammer Bug Report: %s</title>\n' % last_found_title)
        f.write(style_decl + '</head>\n<body>' + md_html)
        f.write('\n\n<div><a href="../vloghammer.html">&larr; Back to VlogHammer Project Page</a></div>\n')
        f.write('</body></html>\n')
        f.close()

f = open(output_dir + '/bugs_open.in', 'w')
for bug in sorted(open_bugs.keys()):
    f.write(open_bugs[bug])
f.close()

# f = open(output_dir + '/bugs_wontfix.in', 'w')
# for bug in sorted(wontfix_bugs.keys()):
#     f.write(wontfix_bugs[bug])
# f.close()

f = open(output_dir + '/bugs_closed.in', 'w')
for bug in sorted(closed_bugs.keys()):
    f.write(closed_bugs[bug])
f.close()

