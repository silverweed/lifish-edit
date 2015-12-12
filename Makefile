build: deps
	crystal build src/LifishEdit.cr

docs:
	crystal docs 

deps:
	shards install
	touch deps
