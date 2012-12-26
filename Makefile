PLANET_VERSION=1.0

all:

bencode.plt: clean
	mkdir planet-build-temp
	(cd planet-build-temp; git clone .. bencode)
	(cd planet-build-temp/bencode; git checkout bencode.plt-${PLANET_VERSION})
	(cd planet-build-temp; raco planet create bencode)
	mv planet-build-temp/bencode.plt .
	rm -rf planet-build-temp

manual.html: manual.scrbl
	raco scribble $<

clean:
	rm -f manual.html racket.css scribble-common.js scribble-style.css scribble.css
	rm -f footnote.css
	rm -rf planet-docs
	rm -f bencode.plt
