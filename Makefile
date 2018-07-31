
# Image URL to use all building/pushing image targets
IMG ?= quay.io/k8s-external-loadbalancer/controller:latest

all: test manager

# Run tests
test: generate fmt vet #manifests
	go test ./pkg/... ./cmd/... -coverprofile cover.out

# Build manager binary
manager: generate fmt vet
	go build -o bin/manager github.com/k8s-external-lb/external-loadbalancer-controller/cmd/manager

# Run against the configured Kubernetes cluster in ~/.kube/config
run: generate fmt vet
	go run ./cmd/manager/main.go

# Install CRDs into a cluster
install: manifests
	kubectl apply -f config/crds

# Deploy controller in the configured Kubernetes cluster in ~/.kube/config
deploy: manifests
	kubectl apply -f config/crds

# Generate manifests e.g. CRD, RBAC etc.
# TODO: need to fix the CRD generator remove the status section. then return the command to all
# manifests:
# 	go run vendor/sigs.k8s.io/controller-tools/cmd/controller-gen/main.go rbac

# Run go fmt against code
fmt:
	go fmt ./pkg/... ./cmd/...

# Run go vet against code
vet:
	go vet ./pkg/... ./cmd/...

# Generate code
generate:
	go generate ./pkg/... ./cmd/...

# Test Inside a docker
docker-test:
	./build-test.sh

# Build the docker image
docker-build: docker-test
	docker build . -t ${IMG}

# Push the docker image
docker-push:
	docker push ${IMG}
