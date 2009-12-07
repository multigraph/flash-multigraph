#!/usr/bin/python

### input: number of colmns to align, number of spaces in between
### output: filename with .align suffixed

def max(a,b):
	if a >= b:
		return a
	else:
		return b

def main(av=None):
	import os
	
	nr_of_delimiters = 4
	nr_of_columns = 0
	filename = ""

	if av is None:
		print "no input, exiting\n", \
				"\t1st arg: filename\n", \
				"\t2nd arg: nr of columns\n" \
				"\t3rd arg: nr of delimiter spaces\n" 
	else:
		print "file: " + av[1]
		filename = av[1]
		print "nr of columns: " + av[2]
		nr_of_columns = int(av[2])
		if len(av) == 4:
			nr_of_delimiters = int(av[3])
		print "nr of delimiters: " , str(nr_of_delimiters)

	if nr_of_columns < 0:
		return
	if len(filename) == 0:
		return

	ifile = ofile = []

	try:
		ifile = open(filename)
		ofile = open(filename + ".new", 'w')
	except IOError:
		print "The file does not exist, exiting gracefully"
		return

	list_column_size = [0]*nr_of_columns
	lines_to_modify = []

	## go in and read the columns, discard if the number of column does not match
	for line_nr, L in enumerate(ifile):
		#print L # test
		L = L.lstrip()
		if len(L) == 0: continue
		if L[0] != '#': ## check if it's a commented line
			split_line = L.split()
			if len(split_line) < nr_of_columns: continue
  			for column_nr in range(nr_of_columns):
				list_column_size[column_nr] = \
					max(len(split_line[column_nr]), list_column_size[column_nr])
			#print line_nr # test
			lines_to_modify.append(line_nr)
			#print line_nr,':', L # test 
		#else:
			#print "skipping line: " + L
	
	print lines_to_modify
	print list_column_size
	
	ifile = open(filename)
	lines = ifile.readlines()
	for m in lines_to_modify:
		columns = lines[m].split()
		print columns
		if len(columns) >= nr_of_columns:
			for i in range(nr_of_columns):
				if len(columns[i]) != list_column_size[i]:
					column_diff = list_column_size[i] - len(columns[i])
					columns[i] = columns[i] + ' '*column_diff
				columns[i] = columns[i] + ' '*nr_of_delimiters
		print columns
		lines[m] = "".join(columns) + "\n"
				
	## write out to output file			
	for L in lines:
		#print L # test
		#ofile.write(L.lstrip())
		ofile.write(L)


import sys
if __name__ == "__main__":
	sys.exit(main(sys.argv))
		
