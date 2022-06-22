# If `venv/bin/python` exists, it is used. If not, use PATH to find python.
SYSTEM_PYTHON  = $(or $(shell which python3), $(shell which python))
PYTHON         = $(or $(wildcard venv/bin/python), $(SYSTEM_PYTHON))

# get the version number
WF_VERSION := $(shell $(PYTHON) src/__version__.py)

# plist values
WF_NAME := alfred-git-repos
WF_CREATEDBY := deanishe
WF_BUNDLEID := com.${WF_CREATEDBY}.${WF_NAME}
WF_DISABLED := false
WF_WEBADDRESS := github.com/${WF_CREATEDBY}
WF_README := README.md
WF_DESCRIPTION := ""

# resulting workflow to build/install
WF_OUTPUT := ${WF_NAME}-${WF_VERSION}.alfredworkflow

# src/build dirs
SRC_DIR := src
BUILD_DIR := build

all: clean build

.PHONY: all

## Environment

venv:
	rm -rf venv
	$(SYSTEM_PYTHON) -m venv venv


deps:
	$(PYTHON) -m pip install \
	--prefer-binary \
	--upgrade \
	-r requirements.txt

.PHONY: deps
.PHONY: venv

## Build, install

build:
	rm -rf ./build/*.egg-info ./build/*.dist-info
	# must use the system python
	$(PYTHON) -m pip install \
		--upgrade \
		--target=./build \
		-r requirements.txt
	rsync --archive --verbose \
		--filter '- *.pyc' \
		--filter '- *.egg-info' \
		--filter '- *.dist-info' \
		--filter '- __pycache__' \
		"$(SRC_DIR)/" "$(BUILD_DIR)/"
	./bin/workflow-build \
		--force --verbose \
		--name="${WF_NAME}" \
		--version="${WF_VERSION}" \
		--createdby="${WF_CREATEDBY}" \
		--bundleid="${WF_BUNDLEID}" \
		--disabled="${WF_DISABLED}" \
		--webaddress="${WF_WEBADDRESS}" \
		--readme="${WF_README}" \
		--description="${WF_DESCRIPTION}" \
		"$(BUILD_DIR)"
	echo "done"

install: $(WF_OUTPUT)
	open $(WF_OUTPUT)

.PHONY: build
.PHONY: install

clean:
	rm -rf \
		requirements.txt \
		./build/ \
		.mypy_cache/ \
		./bin/.site-packages/ \
		*.alfredworkflow

.PHONY: clean