#!/usr/bin/python

import re
import sys
import getopt

opts, args = getopt.getopt(sys.argv, "", [])
args.pop(0)

#############################################################################
# Parse sim log files to 'data' structure
#############################################################################

data = { }
re_parse_pat = re.compile('\\+\\+PAT\\+\\+ +(\S+) +(\S+) +(\S+) +(\S+)')
re_parse_val = re.compile('\\+\\+VAL\\+\\+ +(\S+) +(\S+) +(\S+) +(\S+)')
for sim in args:
  sim_outfile = open("sim_"+sim+".log", "r")
  for line in sim_outfile:
    m = re_parse_pat.search(line)
    if m:
      if not m.group(1) in data:
        data[m.group(1)] = { 'inputs': { }, 'raw_outputs': { }, 'grouped_outputs': { } }
      data[m.group(1)]['inputs'][m.group(2)] = [ m.group(3), m.group(4) ]
    m = re_parse_val.search(line)
    if m:
      data[m.group(1)]['raw_outputs'][sim+"."+m.group(2)] = [ m.group(3), m.group(4) ]

#############################################################################
# Group identical outputs in 'data' structure
#############################################################################

for pat in data.keys():
  reverse_map = { }
  for entry in data[pat]['raw_outputs']:
    rev_key = " ".join(data[pat]['raw_outputs'][entry])
    if not rev_key in reverse_map:
      reverse_map[rev_key] = []
    reverse_map[rev_key].append(entry)
  for rev_key in reverse_map:
    reverse_map[rev_key].sort()
    d = str.split(rev_key, ' ')
    k = ", ".join(reverse_map[rev_key])
    data[pat]['grouped_outputs'][k] = d

#############################################################################
# Generate HTML table for each data record
#############################################################################

for pat in sorted(data.keys()):
  d = data[pat];
  if len(d['grouped_outputs']) > 1:
    print '<table class="valuestab"><tr><th></th><th>binary</th><th>decimal</th></tr>'
    for key in sorted(d['inputs'].keys()):
      print '<tr><td>{}</td><td>{}</td><td>{}</td></tr>'.format(key, d['inputs'][key][0], d['inputs'][key][1])
    for key in sorted(d['grouped_outputs'].keys()):
      print '<tr><td>{}</td><td>{}</td><td>{}</td></tr>'.format(key, d['grouped_outputs'][key][0], d['grouped_outputs'][key][1])
    print '</table>'

