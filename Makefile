build: deps
	crystal build src/LifishEdit.cr -o lifishedit --link-flags -L$(PWD)/foreign

docs:
	crystal docs 

deps:
	shards install
	touch deps
