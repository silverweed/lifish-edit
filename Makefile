UNAME := $(shell uname)
NCORES = 1
EXE = lifishedit
ifeq ($(UNAME), Darwin)
	NCORES = $(shell sysctl -n hw.ncpu)
	CRYSTAL = crystal
endif
ifeq ($(UNAME), Linux)
	NCORES = $(shell lscpu | grep -m1 'CPU(s)' | cut -f2 -d:)
	CRYSTAL = /usr/local/src/crystal-0.23.1-3/bin/crystal
endif

build: deps $(EXE)
	$(CRYSTAL) build -d --threads $(NCORES) src/LifishEdit.cr -o $(EXE) --link-flags -L$(PWD)/foreign/$(shell uname)

release: deps $(EXE)
	$(CRYSTAL) build --release --threads $(NCORES) src/LifishEdit.cr -o $(EXE) --link-flags -L$(PWD)/foreign/$(shell uname)

docs:
	$(CRYSTAL) docs

deps:
	shards install
	touch deps

bundle: release
	./makeapp_osx.sh

.PHONY: clean
clean:
	rm -f $(EXE)

.PHONY: $(EXE)
