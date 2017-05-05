FROM mysql:8

RUN apt-get update && apt-get -y install curl unzip awscli
RUN curl -LO https://github.com/datacharmer/test_db/archive/master.zip
RUN unzip master.zip
ADD etc/dockerfiles/mysql/bootstrap.sh /docker-entrypoint-initdb.d/bootstrap.sh
ADD etc/dockerfiles/common.sh /common.sh
ADD etc/dockerfiles/mysql/run.sh /run.sh
ADD etc/dockerfiles/mysql/custom_entrypoint.sh /custom_entrypoint.sh

ENTRYPOINT ["/custom_entrypoint.sh"]