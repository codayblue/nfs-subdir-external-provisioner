# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(REGISTRY),)
        REGISTRY = quay.io/external_storage/
endif
ifeq ($(VERSION),)
        VERSION = latest
endif
ARCHS = amd64 arm64v8 arm32v7
IMAGE = $(REGISTRY)nfs-subdir-external-provisioner:$(VERSION)
# IMAGE_ARM = $(REGISTRY)nfs-subdir-external-provisioner-arm:$(VERSION) 
# IMAGE_ARM64 = $(REGISTRY)nfs-subdir-external-provisioner-arm64:$(VERSION) 
MUTABLE_IMAGE = $(REGISTRY)nfs-subdir-external-provisioner:latest
# MUTABLE_IMAGE_ARM = $(REGISTRY)nfs-subdir-external-provisioner-arm:latest
# MUTABLE_IMAGE_ARM64 = $(REGISTRY)nfs-subdir-external-provisioner-arm64:latest

all: build build_arm build_arm64 image

container: build build_arm build_arm64 image

build:
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o docker/linux/amd64/nfs-subdir-external-provisioner ./cmd/nfs-subdir-external-provisioner

build_arm:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 go build -a -ldflags '-extldflags "-static"' -o docker/linux/arm/v7/nfs-subdir-external-provisioner ./cmd/nfs-subdir-external-provisioner 

build_arm64:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -ldflags '-extldflags "-static"' -o docker/linux/arm64/nfs-subdir-external-provisioner ./cmd/nfs-subdir-external-provisioner 

image:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx build --push --platform linux/amd64,linux/arm,linux/arm64 --tag $(MUTABLE_IMAGE) docker

push:
	docker push $(IMAGE)
	docker push $(MUTABLE_IMAGE)
	docker push $(IMAGE_ARM)
	docker push $(MUTABLE_IMAGE_ARM)
	docker push $(IMAGE_ARM64)
	docker push $(MUTABLE_IMAGE_ARM64)
