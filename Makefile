IMAGE := quay.io/slok/kube-code-generator:v1.20.1

GROUPS_VERSION := lpai.chj:v1alpha1
DIRECTORY := $(PWD)
PROJECT_PACKAGE := github.com/xdchangfu/generator-inference-client
DEPS_CMD := go mod tidy

default: generate

.PHONY: test
test: 
	go test ./...

.PHONY: generate
generate: generate-client test 

.PHONY: generate-client
generate-client:
	docker run -it --rm \
	-v $(DIRECTORY):/go/src/$(PROJECT_PACKAGE) \
	-e PROJECT_PACKAGE=$(PROJECT_PACKAGE) \
	-e CLIENT_GENERATOR_OUT=$(PROJECT_PACKAGE)/client \
	-e APIS_ROOT=$(PROJECT_PACKAGE)/apis \
	-e GROUPS_VERSION="$(GROUPS_VERSION)" \
	-e GENERATION_TARGETS="deepcopy,client,lister,informer" \
	-e GOPROXY=https://goproxy.cn,direct \
    -e GOPRIVATE=gitlab.chehejia.com \
	$(IMAGE)

.PHONY: generate-crd
generate-crd:
	docker run -it --rm \
	-v $(DIRECTORY):/go/src/$(PROJECT_PACKAGE) \
	-e GO_PROJECT_ROOT=/go/src \
	-e CRD_TYPES_PATH=/go/src/$(PROJECT_PACKAGE)/apis \
	-e CRD_OUT_PATH=/go/src/$(PROJECT_PACKAGE)/manifests \
	$(IMAGE) update-crd.sh

.PHONY: deps
deps:
	$(DEPS_CMD)

.PHONY: clean
clean:
	echo "Cleaning generated files..."
	rm -rf ./manifests/*
	rm -rf ./client/*
	#rm -rf ./apis/v1alpha1/zz_generated.deepcopy.go
