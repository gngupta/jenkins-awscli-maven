.PHONY: all build run stop help

REPO = jenkins-awscli-maven
DOCKERUSER = gorakh
IMGFULLNAME = $(DOCKERUSER)/$(REPO)
CONTAINER_NAME = $(REPO)-container

VERSION ?= latest
PORTS_MAPPING ?= -p 8080:8080 -p 50000:50000

#DATA_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/data

# --------------------------------------------------------------------
# Defaults.
# --------------------------------------------------------------------

all: run

# --------------------------------------------------------------------
# Targets.
# --------------------------------------------------------------------

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build docker image from Dockerfile 
	@docker build -t $(IMGFULLNAME):$(VERSION) .

ifeq ($(shell docker ps -a --format "{{.Status}}" --filter "name=$(CONTAINER_NAME)" | grep -o -m 1 -h Up), Up)
run: ## Run docker image. It will assign default $CONTAINER_NAME and will reuse same name after restart.
	@echo "Looks like container with name ${CONTAINER_NAME} already running. You can stop it with make stop"
else ifeq ($(shell docker ps -a --format "{{.Status}}" --filter "name=$(CONTAINER_NAME)" | grep -o -m 1 -h 'Exited'), Exited)
run:
	@echo "We already have container with name ${CONTAINER_NAME} but it stopped. Going to start"
	@docker start $(CONTAINER_NAME)
else
run:
	@echo "We do not have container with required name, going to start with name ${CONTAINER_NAME}"
	@mkdir -p $(DATA_DIR) && chown -R 1000:1000 $(DATA_DIR)
	@docker run --name $(CONTAINER_NAME) $(PORTS_MAPPING) -v $(DATA_DIR):/var/jenkins_home $(IMGFULLNAME)
endif

stop: ## Stop container with default name
	@docker stop $(CONTAINER_NAME)
