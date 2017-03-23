UNAME := $(shell uname)
NCORES = 1
ifeq ($(UNAME), Darwin)
	NCORES = $(shell sysctl -n hw.ncpu)
endif
ifeq ($(UNAME), Linux)
	NCORES = $(shell lscpu | grep -m1 'CPU(s)' | cut -f2 -d:)
endif

build: deps
	crystal build -d --threads $(NCORES) src/LifishEdit.cr -o lifishedit --link-flags -L$(PWD)/foreign/$(shell uname)

release: deps
	crystal build --release --threads $(NCORES) src/LifishEdit.cr -o lifishedit --link-flags -L$(PWD)/foreign/$(shell uname)

docs:
	crystal docs 

deps:
	shards install
	touch deps

bundle: release
	./makeapp_osx.sh
