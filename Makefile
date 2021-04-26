UID := $(shell id -u)
GID := $(shell id -g)
THIS_FILE := $(lastword $(MAKEFILE_LIST))
TS=.ts
CONTAINER-LIST = $(shell cat $(TS)/container-list 2>/dev/null)

##
## Services
## -------
##

.PHONY: pull
pull: ## 🛒 Pull docker images.
pull: docker-compose.yml $(TS)/pull

$(TS)/pull: docker-compose.yml
	@$(MAKE) -s -f $(THIS_FILE) docker/pull || (echo '⛔ Fail target $@ ⛔'; exit 1;)
	@mkdir -p $(TS)
	@touch $@

.PHONY: setup
setup: ## 🏭 Setup containers.
setup: pull start $(TS)/setup
setup:
	@echo "⌛ Wait for service" && ./waituntil.sh
	@echo "📝 Update credentials" \
		&& docker run -it --rm --network=sonarqube_sonarnet \
			jbergknoff/postgresql-client \
				postgresql://sonar:sonar@sonarqube-db:5432/sonar -c "\x" -c "update users set reset_password=false where login = 'admin'";
# @curl -X POST -u admin:admin \
# 	-d "login=admin" \
# 	-d "password=admin1" \
# 	-d "previousPassword=admin" http://localhost:9999/api/users/change_password 
# @curl -X POST -u admin:1admin \
# 	-d "login=admin" \
# 	-d "password=admin" \
# 	-d "previousPassword=admin" http://localhost:9999/api/users/change_password 

$(TS)/setup:
	@$(MAKE) -s -f $(THIS_FILE) docker/build || (echo '⛔ Fail target $@ ⛔'; exit 1;)
	@$(MAKE) -s -f $(THIS_FILE) start || (echo '⛔ Fail target $@ ⛔'; exit 1;)
	@mkdir -p $(TS)
	@touch $@

.PHONY: start
start: ## 🚀 Run dev environment.
start: DOCKER-ACTION=up -d --remove-orphans sonarqube sonarqube-db
start: docker

.PHONY: stop
stop: ## ⛔ Stop all docker containers.
stop: docker/stop

.PHONY: status
status: ## 📊 Show docker status.
status: docker/ps

.PHONY: config
config: ## 📄 Show config.
config: docker/config 

.PHONY: clean
clean: ## 🚿 Clean the build artifacts.
clean: docker/clean
	@rm -rf $(TS)

##
## Projects
## -------
##

.PHONY: cdev2
cdev2: ## 📳 Analize cdev2.
cdev2: setup
	@./cdev2.sh

.PHONY: flash
flash: ## ⚡ Analize flash.
flash: setup
	@./flash.sh

.PHONY: saas
saas: ## 🚚 Analize saas.
saas: setup
	@./saas.sh

.PHONY: falcon
falcon: ## 🛸 Analize falcon.
falcon: setup
	@./falcon.sh

.PHONY: qm-events
qm-events: ## 💠 Analize qm-events.
qm-events: setup
	@./qm-events.sh	

.PHONY: stork
stork: ## 📅 Analize stork.
stork: setup
	@./stork.sh	

.PHONY: t_and_t
t_and_t: ## 🎁 Analize track & trace.
t_and_t: setup
	@./t_and_t.sh	

##
## Utils
## -------
##

##  
## 🐳 Docker targets.
## 

.PHONY: docker/pull
docker/pull: DOCKER-ACTION:=pull ${CONTAINER-LIST} ## 🐳 Get all docker images.
docker/pull: docker

.PHONY: docker/build
docker/build: DOCKER-ACTION:=build --parallel ${CONTAINER-LIST} ## 🐳 Build all docker images.
docker/build: docker

.PHONY: docker/down
docker/down: DOCKER-ACTION=down ## 🐳 Down docker containers process.
docker/down: docker

.PHONY: docker/stop
docker/stop: DOCKER-ACTION=stop ## 🐳 Stop docker containers process.
docker/stop: docker

.PHONY: docker/clean
docker/clean: DOCKER-ACTION=down -v --remove-orphans ## 🐳 Remove all docker containers, networks and volumen.
docker/clean: docker

.PHONY: docker/ps
docker/ps: DOCKER-ACTION=ps ## 🐳 Show docker process.
docker/ps: docker

.PHONY: docker/config
docker/config: ## 🐳 Show docker-compose config.
	@export UID=${UID} GID=${GID}; \
	 docker-compose config

.PHONY: docker
docker: ## 🐳 Run docker command.
docker: $(TS)/container-list
	@if [ "x_${DOCKER-ACTION}_x" = "x__x" ] || [ "x_${CONTAINER-LIST}_x" = "x__x" ]; then \
		exit 0; \
	else \
		export UID=${UID} GID=${GID} DOCKER_BUILDKIT=1 PROJECT_SOURCE=${PWD}; \
	 ( ((echo ${DOCKER-ACTION} | grep -q -v down) \
	 	&& docker-compose up \
	 		--remove-orphans \
	 		--no-recreate \
	 		--no-start ${CONTAINER-LIST}) || true ) \
	&& docker-compose ${DOCKER-ACTION}; \
	fi

##
## Help
## -------
##

.DEFAULT_GOAL := help
.PHONY: help
help: ## 🆘 Show make targets.
	@grep -E '(^([a-zA-Z_-]|/|-)+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

$(TS)/container-list: docker-compose.yml
	@mkdir -p $(TS)
	@docker run --rm -i -v ${PWD}:/workdir mikefarah/yq eval '.services.* | path | .[-1]' -C -e docker-compose.yml | sed ':a;$!N;s/\n/ /;ta;s/,,/\n\n/g'>$(TS)/container-list
	@touch $(TS)/container-list
