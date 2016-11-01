OUT_DIR=out
SOURCES = $(wildcard *.adoc)
PDF = $(SOURCES:.adoc=.pdf)

LAYOUT:=/templates/asciidoctor-pdf-extensions.rb
#ATTRIBUTES:=-a imagesdir=/templates/icons -a imagesdir=`pwd` -a pdf-stylesdir=/templates/themes -a pdf-style=default -a includedir=/templates
ATTRIBUTES:=-a imagesdir=./ -a pdf-stylesdir=/templates/themes -a pdf-style=default -a includedir=/templates

VOLUMES:=-v `pwd`/../template/:/templates/ -v `pwd`:/documents/

ifeq (,$(wildcard /.dockerenv))
	DOCK := linux
else
	DOCK := windows
endif

 # linux or windows

ifeq ($(DOCK), windows)
	CMD_PDF := asciidoctor-pdf -r $(LAYOUT) $(ATTRIBUTES)
else
	CMD_PDF := docker run -it --rm $(VOLUMES) asciidoctor/docker-asciidoctor asciidoctor-pdf -r $(LAYOUT) $(ATTRIBUTES)
endif

all: dir $(PDF)
	-@ls -l $(OUT_DIR)

%.pdf: %.adoc
	$(CMD_PDF) -o $(OUT_DIR)/$@ $<
	
dir:
	-@mkdir -p $(OUT_DIR)

clean:
	rm -rf $(OUT_DIR)
	rm -vf `find . | grep '~'`
	rm -vf *.pdf

.PHONY: clean dir

