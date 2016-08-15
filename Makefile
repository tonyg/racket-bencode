PACKAGENAME=bencode-codec
COLLECTS=bencode-codec

all: setup

clean:
	find . -name compiled -type d | xargs rm -rf
	rm -rf bencode-codec/doc

setup:
	raco setup $(COLLECTS)

link:
	raco pkg install --link -n $(PACKAGENAME) $$(pwd)

unlink:
	raco pkg remove $(PACKAGENAME)
