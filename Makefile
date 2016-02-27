build: deps
	crystal build src/LifishEdit.cr -o lifishedit

docs:
	crystal docs 

deps:
	shards install
	touch deps
