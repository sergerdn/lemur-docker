.DEFAULT_GOAL=all
.PHONY: clean all copy_env_files lemur_checkout build_containers start_containers

PWD := $(shell pwd)

# TODO: for future use, will tag docker build
COMMIT := $(shell git rev-list -1 HEAD)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION := $(shell git describe --tags --always)

LEMUR_GIT_DIR = lemur-build-docker/.lemur

clean:
	rm -rf $(LEMUR_GIT_DIR)
	docker ps && docker-compose down -v || sudo docker-compose down -v

all:
	$(MAKE) copy_env_files
	$(MAKE) lemur_checkout
	$(MAKE) build_containers
	$(MAKE) start_containers

copy_env_files:
	[ -d .lemur.env ] || cp .lemur.env.dist .lemur.env && echo ".lemur.env created from scratch"
	[ -d .pgsql.env.dist ] || cp .pgsql.env.dist .pgsql.env && echo ".pgsql.env created from scratch"

lemur_checkout:
	[ -d $(LEMUR_GIT_DIR) ] || git clone --depth=1 https://github.com/Netflix/lemur.git $(LEMUR_GIT_DIR)
	cd $(LEMUR_GIT_DIR) && git pull

build_containers:
	docker ps && docker-compose build || sudo docker-compose build

start_containers:
	docker ps && docker-compose up -d || sudo docker-compose up -d
