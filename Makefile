# $ make
# $ make all
all: info

GIT = git
BASE = base
POSTGRESQL = postgresql
MINICONDA = miniconda
DOCKER = docker
VAULT = vault-local vault-external
KUBERNETES = k8s-common minikube k8s-aws
JENKINS = jenkins
.PHONY: info $(GIT) $(BASE) $(POSTGRESQL) $(MINICONDA) $(DOCKER) $(VAULT) $(KUBERNETES) $(JENKINS)

# $ make info
info:
	@echo "GIT: $(GIT)"
	@echo "BASE: $(BASE)"
	@echo "POSTGRESQL: $(POSTGRESQL)"
	@echo "MINICONDA: $(MINICONDA)"
	@echo "DOCKER: $(DOCKER)"
	@echo "VAULT: $(VAULT)"
	@echo "KUBERNETES: $(KUBERNETES)"
	@echo "JENKINS $(JENKINS)"

# $ make git
git:
	@bash ./scripts/git.sh

# $ make base
base:
	@bash ./scripts/base.sh

# $ make postgresql
postgresql:
	@bash ./scripts/postgresql.sh

# $ make miniconda
miniconda:
	@bash ./scripts/miniconda/miniconda.sh

# $ make docker
docker:
	@bash ./scripts/docker.sh

# $ make vault-local
vault-local:
	@bash ./scripts/vault/local.sh
# $ make vault-external
vault-external:
	@bash ./scripts/vault/external.sh

# $ make k8s-common
k8s-common:
	@bash ./scripts/kubernetes/kubernetes.sh
# $ make minikube
minikube:
	@bash ./scripts/kubernetes/minikube.sh
# $ make k8s-aws
k8s-aws:
	@bash ./scripts/kubernetes/aws/kubernetes.sh

# $ make jenkins
jenkins:
	@bash ./scripts/jenkins.sh