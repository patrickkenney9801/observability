SHELL := /bin/bash

PROFILE := observability

apply:
	@cd flux;\
	terraform init;\
	terraform plan;\
	terraform apply;\

dependencies: dependencies-asdf

dependencies-asdf:
	@echo "Updating asdf plugins..."
	@asdf plugin update --all >/dev/null 2>&1 || true
	@echo "Adding new asdf plugins..."
	@cut -d" " -f1 ./.tool-versions | xargs -I % asdf plugin-add % >/dev/null 2>&1 || true
	@echo "Installing asdf tools..."
	@cat ./.tool-versions | xargs -I{} bash -c 'asdf install {}'
	@echo "Updating local environment to use proper tool versions..."
	@cat ./.tool-versions | xargs -I{} bash -c 'asdf local {}'
	@asdf reshim
	@echo "Done!"

start-minikube:
	@minikube -p ${PROFILE} start

stop-minikube:
	@minikube -p ${PROFILE} stop

delete-minikube:
	@minikube -p ${PROFILE} delete

hooks:
	@pre-commit install --hook-type pre-commit
	@pre-commit install-hooks

pre-commit:
	@pre-commit run -a
