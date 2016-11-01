
## This script is for Windows docker
docker run -it -v /$(pwd):/documents/ \
-v /$(pwd)/../template/:/templates/ \
asciidoctor/docker-asciidoctor
