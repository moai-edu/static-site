ifneq (,$(wildcard ./.env))
    include .env
    export
endif

ifneq (,$(wildcard ./.env.local))
    include .env.local
    export
endif

STAGE?=dev

.PHONY: all dev build clean

dev: hugo.toml
	hugo server -D

all: build

build: hugo.toml
	hugo build -D --minify

clean:
	rm -rf public


.PHONY: setup teardown
setup: hugo.toml
	@echo "setup $(STAGE)"
	npx sst deploy --stage $(STAGE)

hugo.toml: hugo.toml.j2
	jinja2 -D baseURL=$(shell if [ "$(STAGE)" = "local" ]; then echo http://localhost:1313; else if [ "$(STAGE)" = "prod" ]; then echo https://$(APEX_SUBDOMAIN).$(DOMAIN); else echo https://$(STAGE)-$(APEX_SUBDOMAIN).$(DOMAIN); fi; fi) $< > $@

teardown:
	@echo "teardown $(STAGE)"
	-npx sst unlock --stage $(STAGE)
	npx sst remove --stage $(STAGE)
