#!/usr/bin/perl -w

use strict;
use English;

my $date = `date "+%Y-%m-%d"`;

print <<EOT;
<html><head>
<title>VlogHammer Report</title>
<script type="text/javascript"><!--
window.onerror = function(msg, url, line)
{
	try {
		var pre = document.createElement("pre");
		pre.appendChild(document.createTextNode("Error \\"" + msg + "\\" in line " + line + "."));
		var div = document.getElementById("error");
		div.appendChild(pre);
		div.style.display = "block";
	} catch (err) {
		/* simply ignore errors from error reporting */
	}
	return false;
};
//--></script>
<style><!--

.report, .about, .banner {
	background-color:	#cca;
	border-width:		1px;
	border-color:		#000;
	border-style:		solid;
	border-radius:		5px;
	margin-bottom:		1em;
}

.banner * td {
	padding-left:		0.5em;
	padding-right:		0.5em;
}


.report pre,
.report table {
	background-color:	#eee;
}

h3 { margin: 0.5em; }
.about div { margin: 0.5em; }

.info { margin: 1em; }
.info:before { content: "Info: "; font-weight:bold; }

.note { margin: 1em; }
.note:before { content: "Error Note: "; font-weight:bold; }

.overviewtab { margin: 0.7em; }
.overviewtab th { width: 90px; }

.valuestab { border-collapse:collapse; border: 2px solid black; }

.valuestab th,
.valuestab td { border-collapse:collapse; border: 1px solid black; }

.valuestab th,
.valuestab td { padding-left: 0.2em; padding-right: 0.2em; }

.valuestab tr:nth-child(1) { background: #ccc; }
.valuestab td.valsimlist { max-width: 300px; }
.valuestab td:nth-last-child(1) { font-family: monospace; text-align: right; min-width: 100px; }
.valuestab td:nth-last-child(2) { font-family: monospace; text-align: right; min-width: 100px; }
.valuestab { margin: 1em; }

.testbench {
	margin: 1em;
	padding: 1em;
	border: 5px dashed gray;
	border-radius: 5px;
	max-width: 900px;
}

--></style>
</head><body onLoad="main();">
<div id=\"loading\">Loading...</div>
<div id=\"error\" style=\"display: none;\"></div>
<div class=\"banner\" id=\"banner\" style=\"display: none;\">

<table width="100%">
<tr>
<td width="100" rowspan="2"><a href="javascript:click_prev()">&lt; PREV</a></td>
<td width="10">List:</td><td width="10"><select id="sel_list" onchange="changed_list()"></select></td>
<td rowspan="2" align="center"><big><b>VlogHammer Report $date</b></big><br/>
<a href="javascript:click_about()">About this report</a> |
<a href="http://www.clifford.at/yosys/vloghammer.html">About VlogHammer</a></td>
<td width="100" rowspan="2" align="right"><a href="javascript:click_next()">NEXT &gt;</a></td></tr>
<tr><td width="10">Report:</td><td width="10"><select id="sel_report" onchange="changed_report()"></select></td></tr>
</table>

</div>
<div class=\"about\" id=\"about\" style=\"display: none;\">
<h3>About this VlogHammer Report</h3>
EOT

if (open(F, "report.in")) {
	print "<div>";
	print while <F>;
	print "</div>";
	close F;
} else {
	print "<div><b>WARNING:</b> No <tt>report.in</tt> file found. Please create this file\n";
	print "with analysis and background information and re-run <tt>bigreport.pl</tt>. A released\n";
	print "report should always contain such background information.</div>";
}

print "</div>\n";

my %lists;

for my $fn (@ARGV)
{
	my $id = $fn;
	$id =~ s,.*/,,;
	$id =~ s,\.html$,,;

	my $state = 0;
	my $in_testbench = 0;
	print "<div class=\"report\" id=\"$id\" style=\"display: none;\">\n";
	print "<h3>Report on $id:</h3>\n";

	open(F, "<$fn");
	while (<F>)
	{
		# next if /^\s*$/;
		if (/^<!-- LISTS:\s+(.*\S)\s+-->/) {
			my @this_lists = split /\s+/, $1;
			for my $list (@this_lists) {
				if (not exists $lists{$list}) {
					$lists{$list} = ( );
				}
				push @{$lists{$list}}, $id;
			}
		}
		if ($state == 1) {
			$state = 0 if /REPORT:END/;
		}
		if ($state == 0) {
			$state = 1 if /REPORT:BEGIN/;
			next;
		}
		if ($state == 1) {
			s,<!--.*?-->,,g;
			# s,<span[^>]*>,,g;
			# s,</span>,,g;
			# $in_testbench = 1 if /^module.*_tb;/;
			if ($in_testbench && /^endmodule/) {
				$in_testbench = 0;
				s/^[^<]*//g;
			}
			print unless $in_testbench;
		}
	}
	close F;

	print "</div>";
}

print <<EOT;
<script><!--
var active_content_id = "";
var reports = [ ], lists = {
EOT

my $first = 1;
for my $list (sort keys %lists) {
	print ",\n" unless $first;
	print "  '$list': [ '" . (join "', '", sort @{$lists{$list}}) . "' ]";
	$first = 0;
}
print "\n";

print <<EOT;
};

function click_prev()
{
	var el = document.getElementById("sel_report");
	if (el.selectedIndex > 0)
		el.selectedIndex--;
	changed_report();
}

function click_next()
{
	var el = document.getElementById("sel_report");
	if (el.selectedIndex < el.children.length-1)
		el.selectedIndex++;
	changed_report();
}

function click_about()
{
	document.getElementById("sel_report").selectedIndex = 0;
	changed_report();
}

function changed_report()
{
	document.getElementById(active_content_id).style.display = "none";
	var report_num = document.getElementById("sel_report").value;

	if (report_num < 0)
		active_content_id = "about";
	else
		active_content_id = reports[report_num];

	document.getElementById(active_content_id).style.display = "block";
}

function update_reports()
{
	var el = document.getElementById("sel_report");
	while (el.firstChild)
		el.removeChild(el.firstChild);

	var op = document.createElement("option");
	op.text = "-- select --";
	op.value = -1;
	el.add(op, null);

	reports = lists[document.getElementById("sel_list").value];
	for (report_num in reports) {
		var op = document.createElement("option");
		op.text = reports[report_num];
		op.value = report_num;
		el.add(op, null);
	}
}

function changed_list()
{
	update_reports();
	click_next();
}

function main()
{
	active_content_id = "about";
	document.getElementById("loading").style.display = "none";
	document.getElementById("banner").style.display = "block";
	document.getElementById("about").style.display = "block";

	var el = document.getElementById("sel_list");
	for (list in lists) {
		var op = document.createElement("option");
		op.text = list;
		el.add(op, null);
	}
	update_reports();
}

//--></script>
</body></html>
EOT

