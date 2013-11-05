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
titles = { }
sorted_keys = []
re_parse_pat = re.compile('\\+\\+PAT\\+\\+ +(\S+) +(\S+) +(\S+) +(\S+) +(\S+)')
re_parse_val = re.compile('\\+\\+VAL\\+\\+ +(\S+) +(\S+) +(\S+) +(\S+)')
for sim in args:
  sim_outfile = open("sim_"+sim+".log", "r")
  for line in sim_outfile:
    m = re_parse_pat.search(line)
    if m:
      if not m.group(2) in data:
        data[m.group(2)] = { 'inputs': { }, 'raw_outputs': { }, 'grouped_outputs': { }, 'split_outputs': { } }
      data[m.group(2)]['inputs'][m.group(3)] = [ m.group(4), m.group(5) ]
      titles[m.group(2)] = "Pattern #{}".format(int(m.group(1)))
      while len(sorted_keys) <= int(m.group(1)):
        sorted_keys.append("")
      sorted_keys[int(m.group(1))] = m.group(2)
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
# Split outputs as indicated in rtl code
#############################################################################

def binary2decimal(bits, signed):
  current_val = 1;
  total_val = 0;
  for i in range(len(bits)):
    if (signed and i == len(bits)-1):
      current_val = -current_val
    if bits[len(bits)-1-i] == '1':
      total_val = total_val + current_val
    elif bits[len(bits)-1-i] != '0':
      return "X"
    current_val = current_val * 2
  return str(total_val)

re_parse_y_wire = re.compile('^\s*wire(\s+signed|)\s*\[(\d+):0\]\s*(y\d+)\s*;\s*$')

f = open('rtl.v', 'r')
bitcounter = 0
bitpartitions = []
for line in f:
  m = re_parse_y_wire.search(line)
  if m:
    bitpartitions.append([ bitcounter, int(m.group(2)) + 1, m.group(3), m.group(1) != "" ])
    bitcounter = bitcounter + int(m.group(2)) + 1
f.close()

for pat in data.keys():
  for lst in data[pat]['grouped_outputs']:
    data[pat]['split_outputs'][lst] = { }
    if len(bitpartitions) == 0:
      data[pat]['split_outputs'][lst]['y'] = data[pat]['grouped_outputs'][lst]
    else:
      for part in bitpartitions:
        data[pat]['split_outputs'][lst][part[2]] = [
            data[pat]['grouped_outputs'][lst][0][part[0]:part[0]+part[1]],
            binary2decimal(data[pat]['grouped_outputs'][lst][0][part[0]:part[0]+part[1]], part[3])
        ]
  if len(bitpartitions) != 0:
    for part in bitpartitions:
      vars_found_diff = False
      ref_lst = data[pat]['split_outputs'].keys()[0]
      for lst in data[pat]['split_outputs'].keys():
        if data[pat]['split_outputs'][lst][part[2]] != data[pat]['split_outputs'][ref_lst][part[2]]:
          vars_found_diff = True
      if not vars_found_diff:
        for lst in data[pat]['split_outputs'].keys():
          del data[pat]['split_outputs'][lst][part[2]]

#############################################################################
# Generate HTML table for each data record
#############################################################################

def outvar_compare(a, b):
    return int(a[1:]) - int(b[1:]);

def pretty_list(txt):
    list = [ token.split('.') for token in txt.split(', ') ]
    ordered_fwd = {}
    ordered_rev = {}
    for token in list:
        i, j = token
        if not i in ordered_fwd:
            ordered_fwd[i] = set()
        if not j in ordered_rev:
            ordered_rev[j] = set()
        ordered_fwd[i].add(j)
        ordered_rev[j].add(i)
    len_orig = len(list)
    len_fwd = len(ordered_fwd)
    len_rev = len(ordered_rev)
    if len_orig * 0.7 < min(len_fwd, len_rev):
        return txt
    if len_fwd < len_rev-1:
        txt = ",<br/>".join([ "%s.{%s}" % (i, ",".join(ordered_fwd[i])) for i in ordered_fwd ])
    else:
        txt = ",<br/>".join([ "{%s}.%s" % (",".join(ordered_rev[j]), j) for j in ordered_rev ])
    return txt

for pat in sorted_keys:
  d = data[pat];
  if len(d['split_outputs']) > 1:
    print '<table class="valuestab" border><tr><th colspan="2" align="left">{}</th><th>binary</th><th>decimal</th></tr>'.format(titles[pat])
    for key in sorted(d['inputs'].keys()):
      print '<tr><td colspan="2">{}</td><td>{}</td><td>{}</td></tr>'.format(key, d['inputs'][key][0], d['inputs'][key][1])
    for lst in sorted(d['split_outputs'].keys()):
      first_var = True
      for var in sorted(d['split_outputs'][lst].keys(), cmp=outvar_compare):
        if first_var:
          print '<tr><td>{}</td><td class="valsimlist" rowspan="{}">{}</td><td>{}</td><td>{}</td></tr>'.format(var,
                len(d['split_outputs'][lst].keys()), pretty_list(lst), d['split_outputs'][lst][var][0], d['split_outputs'][lst][var][1])
        else:
          print '<tr><td>{}</td><td>{}</td><td>{}</td></tr>'.format(var, d['split_outputs'][lst][var][0], d['split_outputs'][lst][var][1])
        first_var = False
    print '</table>'

