# If you're pushing to an integrated registry
# in Openshift, REMOTE will look something like this

# REMOTE=172.30.242.71:5000/myproject

REMOTE?=manyangled
BASENAME?=k8s-native
TAG?=latest

DISTRO_PATH=$(SPARK_DISTRO_PATH)
DISTRO_NAME=$(SPARK_DISTRO_NAME)

BASEIMAGE=$(REMOTE)/$(BASENAME)-base:$(TAG)
DRIVERIMAGE=$(REMOTE)/$(BASENAME)-driver:$(TAG)
EXECUTORIMAGE=$(REMOTE)/$(BASENAME)-executor:$(TAG) 

.PHONY: build push

build_base:
	cp $(DISTRO_PATH)/$(DISTRO_NAME).tgz .
	docker build -f Dockerfile --build-arg DISTRO_TAR=$(DISTRO_NAME).tgz --build-arg DISTRO_NAME=$(DISTRO_NAME) -t $(BASEIMAGE) .

build_driver: build_base
	echo "FROM $(BASEIMAGE)" > Dockerfile-driver
	cat driver-docker.txt >> Dockerfile-driver
	docker build -f Dockerfile-driver -t $(DRIVERIMAGE) .

build_executor: build_base
	echo "FROM $(BASEIMAGE)" > Dockerfile-executor
	cat executor-docker.txt >> Dockerfile-executor
	docker build -f Dockerfile-executor -t $(EXECUTORIMAGE) .

build: build_driver build_executor

push: build
	docker push $(BASEIMAGE)
	docker push $(DRIVERIMAGE)
	docker push $(EXECUTORIMAGE)
