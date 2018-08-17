import sys
import re
import os.path
#from subprocess import Popen, PIPE, STDOUT

unique_import_id={}
UIL="'UNIQUE +IMPORT +LABEL'"
UII="'UNIQUE +IMPORT +ID'"
use_agens=False
ipc=""

def proc(ls):
	if(re.search('^(?i)SCHEMA +AWAIT', ls)):
		return ""

	if(re.search('^(?i)(CREATE|DROP) +CONSTRAINT .+UNIQUE +IMPORT', ls)):
		return ""

	if(re.search('^(?i)MATCH .+ REMOVE .+', ls)):
		return ""

	ls = re.sub("'", "''", ls)
	ls = re.sub(r'\\"([\},])', r"\\\\'\1", ls)
	ls = re.sub(r'([^\\])(`|")', r"\1'", ls)
	ls = re.sub(r'\\"', '"', ls)
	ls = re.sub(r'^(?i)\s*BEGIN\s*$', r'BEGIN;\n', ls)
	ls = re.sub(r'^(?i)\s*COMMIT\s*$', r'COMMIT;\n', ls)

	st = r"(?i)CREATE +\(:'(\S+)':" + UIL + r" +\{(.+), " + UII + r':(\d+)\}\);'
	m1 = re.search(st, ls)
	if m1:
		vlabel = m1.group(1)
		keyval = m1.group(2)
		s_id = m1.group(3)
		unique_import_id[s_id] = vlabel + "\t" + keyval
		ls = re.sub(r"^(?i)CREATE +\(:'(\S+)':" + UIL + r" +\{", 'CREATE (:' + vlabel + ' {', ls) 
		ls = re.sub(r", +" + UII + r":\d+\}", "}", ls)

	st = r"^(?i)MATCH +\(n1:" + UIL + r"(\{" + UII + ":\d+\})\), +\(n2:" + UIL + "({" + UII + ":\d+\})\)"
	m1 = re.search(st, ls)
	if m1:
		n1 = m1.group(1)
		n2 = m1.group(2)
		ls = re.sub(UIL, "", ls)
		ls = re.sub(r"(?i)\[r:'(\S+)'\]", r"[r:\1]", ls)
		ls = re.sub(r"(?i)\[:'(\S+)'\]", r"[:\1]", ls)
		m2 = re.search(r'(\d+)', n1)
		if m2:
			s_id = unique_import_id.get(m2.group(1))
			s_id = re.sub(r"\t", " {", s_id) + '}'
			ls = re.sub(r'(?i)' + n1, s_id, ls)
		m2 = re.search(r'(\d+)', n2)
		if m2:
			s_id = unique_import_id.get(m2.group(1))
			s_id = re.sub(r"\t", " {", s_id) + '}'
			ls = re.sub(r'(?i)' + n2, s_id, ls)

	st = r"^(?i)CREATE +\(:'(\S+)'"
	m1 = re.search(st, ls)
	if m1:
		ls = re.sub(st, r'CREATE (:\1')

	st = r"^(?i)CREATE +INDEX +ON +:"
	m1 = re.search(st, ls)
	if m1:
		ls = re.sub(st, 'CREATE PROPERTY INDEX ON ', ls)
		ls = re.sub("'", '', ls)

	st = r"^(?i)CREATE +CONSTRAINT +ON +\(\S+:'(\S+)'\) +ASSERT +\S+\.'(\S+)'"
	m1 = re.search(st, ls)
	if m1:
		ls = re.sub(st, r"CREATE CONSTRAINT ON \1 ASSERT \2", ls)

	st = r"^(?i)MATCH +\(n1:'(\S+)'"
	m1 = re.search(st, ls)
	if m1:
		ls = re.sub(r"^(?i)MATCH +\(n1:'(\S+)'\s*\{", r"MATCH (n1:\1 {", ls)
		ls = re.sub(r"(?i) +\(n2:'(\S+)'\s*\{", r" (n2:\1 {", ls)
		ls = re.sub(r"(?i)\[:'(\S+)'\]", r"[:\1]", ls)

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
	if use_agens:
		#global ipc
		#ipc.stdin.write(line + "\n")
		#ipc.stdin.close()
		#print ipc.stdout.read()
	else:
		print line,

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
			print ("USAGE: python " + sys.argv[0] + " [--import-to-agens] [--graph=GRAPH_NAME] [--help] [filename (optional if STDIN is provided)]")
			print ("   Additional optional parameters for the AgensGraph integration:")
			print ("      [--dbname=DBNAME] : Database name")
			print ("      [--host=HOST]     : Hostname or IP")
			print ("      [--port=PORT]     : Port")
			print ("      [--username=USER] : Username")
			print ("      [--no-password]   : No password")
			print ("      [--password]      : Ask password (should happen automatically)")
			exit(0)
		s_file=arg
	if not graph_name:
		print ("Please specify the --graph= parameter to initialize the graph repository.")
		exit(1)
	if s_file:
		if not os.path.isfile(s_file):
			print ("File not found: " + s_file)
			exit(1)
	graph_st=make_graph_st(graph_name)
	if use_agens:
		#global ipc
		#ipc = Popen(['agens', opt], stdout=PIPE, stdin=PIPE, stderr=STDOUT)
		#ipc.stdin.write(graph_st + "\n")
		#ipc.stdin.close()
		#print ipc.stdout.read()
		print "Integration with AgensGraph is currently not supported"
		exit 1
	else:
		print graph_st

	if not s_file == "":
		x=load_file(s_file)
		for ls in x:
			out(ls)
	else:
		for ls in sys.stdin:
			out(ls)
	if use_agens:
		ipc.terminate()
		ipc.kill()

main()

