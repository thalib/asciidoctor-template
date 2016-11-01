# -*- makefile -*-
ATTRIBUTES=-a imagesdir=${TOPDIR}/templates/icons \
	   -a pdf-stylesdir=${TOPDIR}/templates/themes \
	   -a pdf-style=default \
	   -a includedir=${TOPDIR}/templates

%.tex: %.adoc ${TOPDIR}/templates/themes
	asciidoctor -b latex ${ATTRIBUTES}  $<

%.xml: %.adoc ${TOPDIR}/templates/themes
	asciidoctor -b docbook ${ATTRIBUTES}  $<

%.pdf: %.adoc ${TOPDIR}/templates/asciidoctor-pdf-extensions.rb ${TOPDIR}/templates/themes/
	asciidoctor-pdf -r ${TOPDIR}/templates/asciidoctor-pdf-extensions.rb ${ATTRIBUTES}  $<
