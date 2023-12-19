SHELL := /bin/bash

PROFILE := observability

define node_ip
$(shell kubectl --context ${PROFILE} get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
endef

define grafana_port
$(shell kubectl --context ${PROFILE} get --namespace grafana -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
endef

define sonarqube_port
$(shell kubectl --context ${PROFILE} get --namespace sonarqube -o jsonpath="{.spec.ports[0].nodePort}" services sonarqube-sonarqube)
endef

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
	@minikube -p ${PROFILE} start \
	--extra-config=kubelet.cpu-manager-policy=static \
	--extra-config=kubelet.reserved-cpus=1

stop-minikube:
	@minikube -p ${PROFILE} stop

delete-minikube:
	@minikube -p ${PROFILE} delete

grafana:
	@echo http://$(call node_ip):$(call grafana_port)
	@python -mwebbrowser http://$(call node_ip):$(call grafana_port)

sonarqube:
	@echo http://$(call node_ip):$(call sonarqube_port)
	@python -mwebbrowser http://$(call node_ip):$(call sonarqube_port)

hooks:
	@pre-commit install --hook-type pre-commit
	@pre-commit install-hooks

pre-commit:
	@pre-commit run -a
