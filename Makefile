ARCH := $(shell dpkg --print-architecture || true)
DOCKER_USER ?= "riggerthegeek"
PASSWORD_SECRET ?= "openfaas_htpasswd"
STACK ?= "func"
WEB_USER ?= "faas"
WEB_PASS ?= ""

ARCH_SUFFIX = ""
COMPOSE_FILE = "docker-compose"
ifeq ($(ARCH), armhf)
COMPOSE_FILE = "docker-compose.${ARCH}"
ARCH_SUFFIX = "-armhf"
endif

deploy:
	docker stack deploy ${STACK} --compose-file ${COMPOSE_FILE}.yml
.PHONY: deploy

destroy:
	docker stack rm ${STACK}
.PHONY: destroy

destroy-secret:
	docker secret rm ${NAME}
.PHONY: destroy-secret

import-secrets:
	rm -f secrets.yml
	gpg -d secrets.yml.gpg > secrets.yml
	python scripts/importSecrets.py
	rm -f secrets.yml
.PHONY: import-secrets

password:
	docker run -it --rm \
		-e USERNAME=${WEB_USER} \
		-e PASSWORD=${WEB_PASS} \
		-v ${PWD}:/opt \
		riggerthegeek/htpasswd:0.1${ARCH_SUFFIX}
	cat htpasswd
.PHONY: password

password-update:
	make password

	make destroy || true
	docker secret rm openfaas_htpasswd || true
	docker secret create openfaas_htpasswd htpasswd
.PHONY: password-update

secret:
	echo -n "${VALUE}" | docker secret create "${NAME}" -
.PHONY: secret

update:
.PHONY: update
