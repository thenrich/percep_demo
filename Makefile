# Prefix to make clean up easier
prefix = perceptyx
curdir = $(shell pwd)
repo_prefix = ${AWSAccountId}.dkr.ecr.${AWSRegion}.amazonaws.com

build-go-builder:
	docker build -t $(prefix)-go-build $(curdir)/etc/dockerfiles/go

prepare-build-context:
	for dir in $(shell ls $(curdir)/etc/dockerfiles); do cp ${curdir}/etc/dockerfiles/common.sh ${dir}/common.sh; done

# Launch the go-build image with the web directory mounted at /app,
# fetch Go dependencies, and install the binary
build-web: build-go-builder
	docker run --rm -it \
		-e GOPATH=/app \
		-e GOOS=linux \
		-v $(curdir)/web:/app \
		-w /app \
		$(prefix)-go-build bash -c "go get -d ./... && go install github.com/thenrich/perceptyx_test github.com/thenrich/perceptyx_test/mysql_check"
	chmod +x $(curdir)/web/bin/*
	docker build -t $(prefix)-web -f $(curdir)/etc/dockerfiles/web/Dockerfile .

build-nginx:
	docker build -t $(prefix)-nginx -f $(curdir)/etc/dockerfiles/nginx/Dockerfile .

build-mysql:
	docker build -t $(prefix)-mysql -f $(curdir)/etc/dockerfiles/mysql/Dockerfile .

build-env-cfg:
	docker build -t $(prefix)-env-cfg -f $(curdir)/etc/dockerfiles/env-cfg/Dockerfile .

start-mysql:
	docker run -d --name $(prefix)-mysql -e MYSQL_ROOT_PASSWORD=demodemo $(prefix)-mysql mysqld

stop-mysql:
	docker rm -f $(prefix)-mysql || true

start-web:
	docker run -d --name $(prefix)-web -p 9090:8080 --link $(prefix)-mysql:mysql -e MYSQL_CONNECTION_STRING="root:demodemo@tcp(mysql:3306)/employees" $(prefix)-web /run.sh

stop-web:
	docker rm -f $(prefix)-web || true

start-nginx:
	docker run -d --name $(prefix)-nginx -p 8080:80 --link $(prefix)-web:web $(prefix)-nginx /run.sh

stop-nginx:
	docker rm -f $(prefix)-nginx || true

push-web: 
	docker tag $(prefix)-web $(repo_prefix)/$(prefix)/$(prefix)-web:latest
	docker push $(repo_prefix)/$(prefix)/$(prefix)-web:latest

push-nginx:
	docker tag $(prefix)-nginx $(repo_prefix)/$(prefix)/$(prefix)-nginx:latest
	docker push $(repo_prefix)/$(prefix)/$(prefix)-nginx:latest

push-mysql:
	docker tag $(prefix)-mysql $(repo_prefix)/$(prefix)/$(prefix)-mysql:latest
	docker push $(repo_prefix)/$(prefix)/$(prefix)-mysql:latest

push-env-cfg:
	docker tag $(prefix)-env-cfg $(repo_prefix)/$(prefix)/$(prefix)-env-cfg:latest
	docker push $(repo_prefix)/$(prefix)/$(prefix)-env-cfg:latest

build-all: build-web build-nginx build-mysql build-env-cfg

push-all: push-web push-nginx push-mysql push-env-cfg

start-all: start-mysql start-web start-nginx

stop-all: stop-mysql stop-web stop-nginx


