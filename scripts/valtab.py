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
cached_data_decimal = { }
re_parse_pat = re.compile('\\+\\+PAT\\+\\+ +(\S+) +(\S+) +(\S+) +(\S+)')
re_parse_val = re.compile('\\+\\+VAL\\+\\+ +(\S+) +(\S+) +(\S+) +(\S+)')
for sim in args:
  sim_outfile = open("sim_"+sim+".log", "r")
  for line in sim_outfile:
    m = re_parse_pat.search(line)
    if m:
      idx = int(m.group(1))
      if not idx in data:
        data[idx] = { 'inputs': { }, 'raw_outputs': { }, 'grouped_outputs': { }, 'split_outputs': { } }
      if not m.group(2) in data[idx]['inputs'] or m.group(4) != "#":
          data[idx]['inputs'][m.group(2)] = [ m.group(3), m.group(4) ]
    m = re_parse_val.search(line)
    if m:
      idx = int(m.group(1))
      if m.group(4) == "#" and m.group(3) in cached_data_decimal:
          data[idx]['raw_outputs'][sim+"."+m.group(2)] = [ m.group(3), cached_data_decimal[m.group(3)] ]
      else:
          data[idx]['raw_outputs'][sim+"."+m.group(2)] = [ m.group(3), m.group(4).upper() ]
          cached_data_decimal[m.group(3)] = m.group(4).upper()

#############################################################################
# Group identical outputs in 'data' structure
#############################################################################

for idx in data.keys():
  reverse_map = { }
  for entry in data[idx]['raw_outputs']:
    rev_key = " ".join(data[idx]['raw_outputs'][entry])
    if not rev_key in reverse_map:
      reverse_map[rev_key] = []
    reverse_map[rev_key].append(entry)
  for rev_key in reverse_map:
    reverse_map[rev_key].sort()
    d = str.split(rev_key, ' ')
    k = ", ".join(reverse_map[rev_key])
    data[idx]['grouped_outputs'][k] = d

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

re_parse_y_wire = re.compile('^\s*(wire|reg)(\s+signed|)\s*\[(\d+):0\]\s*(y\d+)\s*;\s*$')

f = open('rtl.v', 'r')
bitcounter = 0
bitpartitions = []
for line in f:
  m = re_parse_y_wire.search(line)
  if m:
    bitpartitions.append([ bitcounter, int(m.group(3)) + 1, m.group(4), m.group(2) != "" ])
    bitcounter = bitcounter + int(m.group(3)) + 1
f.close()

for idx in data.keys():
  for lst in data[idx]['grouped_outputs']:
    data[idx]['split_outputs'][lst] = { }
    if len(bitpartitions) == 0:
      data[idx]['split_outputs'][lst]['y'] = data[idx]['grouped_outputs'][lst]
    else:
      for part in bitpartitions:
        data[idx]['split_outputs'][lst][part[2]] = [
            data[idx]['grouped_outputs'][lst][0][part[0]:part[0]+part[1]],
            binary2decimal(data[idx]['grouped_outputs'][lst][0][part[0]:part[0]+part[1]], part[3])
        ]
  if len(bitpartitions) != 0:
    for part in bitpartitions:
      vars_found_diff = False
      ref_lst = data[idx]['split_outputs'].keys()[0]
      for lst in data[idx]['split_outputs'].keys():
        if data[idx]['split_outputs'][lst][part[2]] != data[idx]['split_outputs'][ref_lst][part[2]]:
          vars_found_diff = True
      if not vars_found_diff:
        for lst in data[idx]['split_outputs'].keys():
          del data[idx]['split_outputs'][lst][part[2]]

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
    if len_fwd < len_rev/2:
        txt = ",<br/>".join([ "%s.{%s}" % (i, ",".join(sorted(ordered_fwd[i]))) for i in ordered_fwd ])
    else:
        txt = ",<br/>".join([ "{%s}.%s" % (",".join(sorted(ordered_rev[j])), j) for j in ordered_rev ])
    return txt

for idx in sorted(data.keys()):
  d = data[idx]
  if len(d['split_outputs']) > 1:
    print '<table class="valuestab" border><tr><th colspan="2" align="left">Pattern #{}</th><th>binary</th><th>decimal</th></tr>'.format(idx)
    first_var = True
    for key in sorted(d['inputs'].keys()):
      if first_var:
        print '<tr><td rowspan="{}">input signals</td><td>{}</td><td>{}</td><td>{}</td></tr>'.format(len(d['inputs']), key, d['inputs'][key][0], d['inputs'][key][1])
      else:
        print '<tr><td>{}</td><td>{}</td><td>{}</td></tr>'.format(key, d['inputs'][key][0], d['inputs'][key][1])
      first_var = False
    for lst in sorted(d['split_outputs'].keys()):
      first_var = True
      for var in sorted(d['split_outputs'][lst].keys(), cmp=outvar_compare):
        if first_var:
          print '<tr><td class="valsimlist" rowspan="{}">{}</td><td>{}</td><td>{}</td><td>{}</td></tr>'.format(
                len(d['split_outputs'][lst].keys()), pretty_list(lst), var, d['split_outputs'][lst][var][0], d['split_outputs'][lst][var][1])
        else:
          print '<tr><td>{}</td><td>{}</td><td>{}</td></tr>'.format(var, d['split_outputs'][lst][var][0], d['split_outputs'][lst][var][1])
        first_var = False
    print '</table>'

