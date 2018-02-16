UNAME := $(shell uname)
NCORES = 1
EXE = lifishedit
ifeq ($(UNAME), Darwin)
	NCORES = $(shell sysctl -n hw.ncpu)
endif
ifeq ($(UNAME), Linux)
	NCORES = $(shell lscpu | grep -m1 'CPU(s)' | cut -f2 -d:)
endif

build: deps $(EXE)
	crystal build -d --threads $(NCORES) src/LifishEdit.cr -o $(EXE) --link-flags -L$(PWD)/foreign/$(shell uname)

release: deps $(EXE)
	crystal build --release --threads $(NCORES) src/LifishEdit.cr -o $(EXE) --link-flags -L$(PWD)/foreign/$(shell uname)

docs:
	crystal docs 

deps:
	shards install
	touch deps

bundle: release
	./makeapp_osx.sh

.PHONY: clean
clean:
	rm -f $(EXE) 

.PHONY: $(EXE)
