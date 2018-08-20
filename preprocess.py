import sys
import re
import os.path
from subprocess import Popen, PIPE, STDOUT

unique_import_id={}
multiple_vlabels={}
UIL="'UNIQUE +IMPORT +LABEL'"
UII="'UNIQUE +IMPORT +ID'"
ipc=""
multiple_vlabel_cnt=0
use_agens=False
mulv_label_name="AG_MULV_"

def set_multiple_vlabel(vertexes, s_property):
	global multiple_vlabel_cnt, multiple_vlabels
	top_vertex="AG_MULV_";
	multiple_vlabel_cnt=multiple_vlabel_cnt + 1
	top_vertex = top_vertex + str(multiple_vlabel_cnt)
	multiple_vlabels[vertexes] = top_vertex + "\t" + s_property
	return top_vertex

def proc(ls):
	global multiple_vlabels
	if re.search('^SCHEMA +AWAIT', ls, flags=re.IGNORECASE):
		return ""

	if re.search('^(CREATE|DROP) +CONSTRAINT .+UNIQUE +IMPORT', ls, flags=re.IGNORECASE):
		return ""

	if re.search('^MATCH .+ REMOVE .+', ls, flags=re.IGNORECASE):
		return ""

	ls = re.sub("'", "''", ls)
	ls = re.sub(r'\\"([\},])', r"\\\\'\1", ls)
	ls = re.sub(r'([^\\])(`|")', r"\1'", ls)
	ls = re.sub(r'\\"', '"', ls)
	ls = re.sub(r'^\s*BEGIN\s*$', r'BEGIN;\n', ls, flags=re.IGNORECASE)
	ls = re.sub(r'^\s*COMMIT\s*$', r'COMMIT;\n', ls, flags=re.IGNORECASE)

	st = r"CREATE +\(:'(\S+)':"+UIL+" +\{"+UII+":(\d+)\}\);"
	m1 = re.search(st, ls, flags=re.IGNORECASE)
	if m1:
		vlabel = m1.group(1)
		s_id = m1.group(2)
		if re.search("':'", vlabel):
			vlabel = re.sub("':'", ":", vlabel)
			vlabel = set_multiple_vlabel(vlabel, "")
			unique_import_id[s_id] = vlabel + "\t"
			return ""
		unique_import_id[s_id] = vlabel + "\t"
		ls = re.sub(r":" + UIL + " +.+", ");", ls)

	st = r"CREATE +\(:'(\S+)':" + UIL + r" +\{(.+), " + UII + r':(\d+)\}\);'
	m1 = re.search(st, ls, flags=re.IGNORECASE)
	if m1:
		vlabel = m1.group(1)
		keyval = m1.group(2)
		s_id = m1.group(3)
		if re.search("':'", vlabel):
			vlabel = re.sub("':'", ":", vlabel)
			vlabel = set_multiple_vlabel(vlabel, keyval)
			unique_import_id[s_id] = vlabel + "\t" + keyval
			return ""
		unique_import_id[s_id] = vlabel + "\t" + keyval
		ls = re.sub(r"^CREATE +\(:'(\S+)':" + UIL + r" +\{", 'CREATE (:' + vlabel + ' {', ls, flags=re.IGNORECASE) 
		ls = re.sub(r", +" + UII + r":\d+\}", "}", ls)

	if (re.search(r"^COMMIT", ls, re.IGNORECASE) and multiple_vlabels):
		if not re.search("(\r|\n)$", ls):
			ls = ls + "\n"
		ls = ls + "BEGIN;\n"

		for key in multiple_vlabels:
			val = multiple_vlabels.get(key)
			val1, s_property = val.split("\t")
			prev=""
			for vlabel in key.split(":"):
				if re.search("\S", s_property):
					ls = ls + "CREATE (:" + vlabel + " { " + s_property + " });\n"
				else:
					if prev != vlabel:
						ls = ls + "CREATE VLABEL " + vlabel + ";\n"
				prev = vlabel

			ls = ls + "CREATE VLABEL " + val1 + " INHERITS ("
			for vlabel in key.split(":"):
				ls = ls + vlabel + ", "
			ls = re.sub(r", $", "", ls)
			ls = ls + ");\n"

		ls = ls + "COMMIT;\n"
		multiple_vlabels = {}

	st = r"^(?i)MATCH +\(n1:" + UIL + r"(\{" + UII + ":\d+\})\), +\(n2:" + UIL + "({" + UII + ":\d+\})\)"
	m1 = re.search(st, ls, re.IGNORECASE)
	if m1:
		n1 = m1.group(1)
		n2 = m1.group(2)
		ls = re.sub(UIL, "", ls)
		ls = re.sub(r"\[r:'(\S+)'\]", r"[r:\1]", ls, flags=re.IGNORECASE)
		ls = re.sub(r"\[:'(\S+)'\]", r"[:\1]", ls, flags=re.IGNORECASE)
		m2 = re.search(r'(\d+)', n1)
		if m2:
			s_id = unique_import_id.get(m2.group(1))
			s_id = re.sub(r"\t", " {", s_id) + '}'
			ls = re.sub(n1, s_id, ls, flags=re.IGNORECASE)
		m2 = re.search(r'(\d+)', n2)
		if m2:
			s_id = unique_import_id.get(m2.group(1))
			s_id = re.sub(r"\t", " {", s_id) + '}'
			ls = re.sub(n2, s_id, ls, flags=re.IGNORECASE)

	st = r"^CREATE +\(:'(\S+)'"
	m1 = re.search(st, ls, flags=re.IGNORECASE)
	if m1:
		ls = re.sub(st, r'CREATE (:\1', ls, flags=re.IGNORECASE)

	st = r"^CREATE +INDEX +ON +:"
	m1 = re.search(st, ls, flags=re.IGNORECASE)
	if m1:
		ls = re.sub(st, 'CREATE PROPERTY INDEX ON ', ls, flags=re.IGNORECASE)
		ls = re.sub("'", '', ls)

	st = r"^CREATE +CONSTRAINT +ON +\(\S+:'(\S+)'\) +ASSERT +\S+\.'(\S+)'"
	m1 = re.search(st, ls, flags=re.IGNORECASE)
	if m1:
		ls = re.sub(st, r"CREATE CONSTRAINT ON \1 ASSERT \2", ls, flags=re.IGNORECASE)

	st = r"^MATCH +\(n1:'*(\S+)'*"
	m1 = re.search(st, ls, flags=re.IGNORECASE)
	if m1:
		ls = re.sub(r"^MATCH +\(n1:'*(\S+)'*\s*\{", r"MATCH (n1:\1 {", ls, flags=re.IGNORECASE)
		ls = re.sub(r" +\(n2:'*(\S+)'*\s*\{", r" (n2:\1 {", ls, flags=re.IGNORECASE)
		ls = re.sub(r"\[:'(\S+)'\]", r"[:\1]", ls, flags=re.IGNORECASE)
		ls = re.sub(r"\[:'(\S+)' ", r"[:\1 ", ls, flags=re.IGNORECASE)

	return ls

def load_file(filename):
	f = open(filename, 'r')
	x = f.readlines()
	f.close()
	return x

def make_graph_st(graph_name):
	return "DROP GRAPH IF EXISTS "+graph_name+" CASCADE;\nCREATE GRAPH "+graph_name+";\nSET GRAPH_PATH="+graph_name+";"

def out(ls):
	global use_agens
	line=""
	m1 = re.search(r'^\s*$', ls)
	if ls == "" or m1:
		return
	line=proc(ls)
	m1 = re.search(r'^\s*$', line)
	if line == "" or m1:
		return
	line=re.sub("(\r|\n)+$", "", line)
	if use_agens:
		global ipc
		line = re.sub("$", "\n", line)
		ipc.stdin.write(line.encode())
	else:
		print(line)

def main():
	global use_agens, graph_st
	graph_name=""
	s_file=""
	graph_st=""
	opt=""

	for arg in sys.argv[1:]:
		if arg == "--import-to-agens":
			use_agens=True
			continue
		m1 = re.search(r'^--graph=(\S+)$', arg)
		if m1:
			graph_name=m1.group(1)
			continue
		m1 = re.search(r'^(--)(dbname|host|port|username)(=\S+)$', arg)
		if m1:
			opt = " " + m1.group(0)
			continue
		m1 = re.search(r'^(--)(no-password|password)$', arg)
		if m1:
			opt = " " + m1.group(0)
			continue
		m1 = re.search(r'^--', arg)
		m2 = re.search(r'^--(h|help)$', arg)
		if m1 or m2:
			print("USAGE: python " + sys.argv[0] + " [--import-to-agens] [--graph=GRAPH_NAME] [--help] [filename (optional if STDIN is provided)]")
			print("   Additional optional parameters for the AgensGraph integration:")
			print("      [--dbname=DBNAME] : Database name")
			print("      [--host=HOST]     : Hostname or IP")
			print("      [--port=PORT]     : Port")
			print("      [--username=USER] : Username")
			print("      [--no-password]   : No password")
			print("      [--password]      : Ask password (should happen automatically)")
			exit(0)
		s_file=arg
	if not graph_name:
		print("Please specify the --graph= parameter to initialize the graph repository.")
		exit(1)
	if s_file:
		if not os.path.isfile(s_file):
			print("File not found: " + s_file)
			exit(1)
	graph_st=make_graph_st(graph_name)
	if use_agens:
		global ipc
		ret = ""
		not_avail = "agens client is not available"
		try:
			ret = Popen(['agens', '--help'], stdin=None, stdout=PIPE, stderr=STDOUT)
		except OSError:
			print(not_avail)
			exit(1)
		ret.wait()
		if ret.returncode != 0:
			print(not_avail)
			exit(1)
		ipc = Popen(['agens', opt], stdin=PIPE, stderr=STDOUT)
		graph_st = re.sub("$", "\n", graph_st)
		ipc.stdin.write(graph_st.encode())
	else:
		print(graph_st)

	if not s_file == "":
		x=load_file(s_file)
		for ls in x:
			out(ls)
	else:
		for ls in sys.stdin:
			out(ls)
	if use_agens:
		ipc.stdin.close()

main()

