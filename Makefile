SHELL := /bin/bash

PROFILE := observability
MINIKUBE_IP := 192.168.49.2

define grafana_port
$(shell kubectl --context ${PROFILE} get --namespace grafana -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
endef

define harbor_port
$(shell kubectl --context ${PROFILE} get --namespace harbor -o jsonpath="{.spec.ports[0].nodePort}" services harbor)
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
	--static-ip ${MINIKUBE_IP} \
	--extra-config=kubelet.cpu-manager-policy=static \
	--extra-config=kubelet.reserved-cpus=1 \
	--addons=ingress,ingress-dns

stop-minikube:
	@minikube -p ${PROFILE} stop

delete-minikube:
	@minikube -p ${PROFILE} delete

services: grafana harbor sonarqube

services-remote:
	@echo ssh -L 9801:${MINIKUBE_IP}:$(call sonarqube_port) \
	 -L 9802:${MINIKUBE_IP}:$(call grafana_port) \
	 -L 9803:${MINIKUBE_IP}:$(call harbor_port) \
	 $(shell hostname)

grafana:
	@echo http://${MINIKUBE_IP}:$(call grafana_port)
	@python -mwebbrowser http://${MINIKUBE_IP}:$(call grafana_port)

harbor:
	@echo "Harbor requires the following setup: https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/"
	@echo http://core.harbor.domain
	@python -mwebbrowser http://core.harbor.domain

sonarqube:
	@echo http://${MINIKUBE_IP}:$(call sonarqube_port)
	@python -mwebbrowser http://${MINIKUBE_IP}:$(call sonarqube_port)

hooks:
	@pre-commit install --hook-type pre-commit
	@pre-commit install-hooks

pre-commit:
	@pre-commit run -a
