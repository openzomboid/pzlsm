# If the first argument is "deploy"...
ifeq (deploy, $(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

deploy:
	@sh scripts/local/deploy.sh $(RUN_ARGS)
