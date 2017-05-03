# Prefix to make clean up easier
prefix = perceptyx
curdir = $(shell pwd)

build-go-builder:
	docker build -t $(prefix)-go-build etc/dockerfiles/go

# Launch the go-build image with the web directory mounted at /app,
# fetch Go dependencies, and install the binary
build-web: build-go-builder
	docker run --rm -it \
		-e GOPATH=/app \
		-e GOOS=linux \
		-v $(curdir)/web:/app \
		-w /app \
		$(prefix)-go-build bash -c "go get -d ./... && go install github.com/thenrich/perceptyx_test"
	mkdir $(curdir)/etc/dockerfiles/web/bin || true
	chmod +x $(curdir)/web/bin/*
	cp $(curdir)/web/bin/* $(curdir)/etc/dockerfiles/web/bin
	docker build -t $(prefix)-web $(curdir)/etc/dockerfiles/web

build-nginx:
	docker build -t $(prefix)-nginx $(curdir)/etc/dockerfiles/nginx

build-mysql:
	docker build -t $(prefix)-mysql $(curdir)/etc/dockerfiles/mysql

start-mysql:
	docker run -d --name $(prefix)-mysql -e MYSQL_ROOT_PASSWORD=demodemo $(prefix)-mysql 

stop-mysql:
	docker rm -f $(prefix)-mysql

start-web:
	docker run -d --name $(prefix)-web -p 9090:8080 --link $(prefix)-mysql:mysql -e MYSQL_CONNECTION_STRING="root:demodemo@tcp(mysql:3306)/employees" $(prefix)-web /app/perceptyx_test

stop-web:
	docker rm -f $(prefix)-web

start-nginx:
	docker run -d --name $(prefix)-nginx -p 8080:80 --link $(prefix)-web:web $(prefix)-nginx nginx -g 'daemon off;'

stop-nginx:
	docker rm -f $(prefix)-nginx

build-all: build-web build-nginx build-mysql

start-all: start-mysql start-web start-nginx

stop-all: stop-mysql stop-web stop-nginx


