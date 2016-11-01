A simple template to generate beautiful document using asciidoctor. 

## Install Docker

The documentation is built using asciidoctor. Installing asciidoctor is a bit difficult in window/linux machine, so use prebuit docker images. 

 curl -fsSL https://get.docker.com/ | sh


## Pull ascii doctor image from docker hub

This image is big, aprox 1.5 GB

 docker pull asciidoctor/docker-asciidoctor
 
 [or]

Alternatively Load ascii doctor image from tar file

 docker load -i ./docker-asciidoctor.tar

## Compile the pdf

### On Linux

 make

### On Windows

 ./start.sh
 
once the docker images is started run make

 make

## Reference

* http://asciidoctor.org/docs/asciidoc-syntax-quick-reference/
