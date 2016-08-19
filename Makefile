SPARK_IMAGE=mattf/openshift-spark

.PHONY: build clean push create destroy

build:
	./copy-builds.sh
	docker build --no-cache=true -t openshift-spark .
	docker tag openshift-spark:latest openshift-spark:scorpion-stare

clean:
	docker rmi openshift-spark

push: build
	docker tag -f openshift-spark $(SPARK_IMAGE)
	docker push $(SPARK_IMAGE)

create: push template.yaml
	oc process -f template.yaml -v SPARK_IMAGE=$(SPARK_IMAGE) > template.active
	oc create -f template.active

destroy: template.active
	oc delete -f template.active
	rm template.active
