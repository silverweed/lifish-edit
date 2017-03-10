build: deps
	crystal build -d --threads 4 src/LifishEdit.cr -o lifishedit --link-flags -L$(PWD)/foreign --link-flags -L$(PWD)/foreign/$(shell uname)

docs:
	crystal docs 

deps:
	shards install
	touch deps
