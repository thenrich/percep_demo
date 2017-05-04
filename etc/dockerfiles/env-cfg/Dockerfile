FROM ubuntu 

RUN apt-get update && apt-get -y install awscli
ADD etc/dockerfiles/common.sh /common.sh
ADD etc/dockerfiles/env-cfg/run.sh /run.sh
