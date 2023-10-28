PREFIX = $(HOME)/.local
PERL_BIN = $(shell which perl)
DRILL_HOME = $(shell pwd)
DRILLS = all.txt
ALL = drill

.SUFFIXES:

.SUFFIXES: .pl

all: ${ALL}

.pl:
	m4 -DDRILL_PERL_BIN=${PERL_BIN} \
		-DDRILL_HOME=${DRILL_HOME} \
		-DDRILL_DRILLS=${DRILLS} \
		$< > $@

clean:
	rm -f ${ALL}

install:
	install drill ${PREFIX}/bin
