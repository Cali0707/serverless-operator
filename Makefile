# Useful for local development
dev:
	./hack/dev.sh

# General purpose targets
images:
	./hack/images.sh $(DOCKER_REPO_OVERRIDE)

install:
	./hack/install.sh

install-operator:
	INSTALL_SERVING="false" INSTALL_EVENTING="false" ./hack/install.sh

install-all:
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh
	./hack/tracing.sh
	SCALE_UP=4 INSTALL_KAFKA="true" ENABLE_TRACING=true ./hack/install.sh

install-tracing:
	./hack/tracing.sh

install-serving:
	INSTALL_EVENTING="false" ./hack/install.sh

install-serving-with-mesh:
	FULL_MESH="true" UNINSTALL_MESH="false" ./hack/mesh.sh
	FULL_MESH=true SCALE_UP=4 INSTALL_SERVING=true INSTALL_EVENTING="false" ./hack/install.sh

install-eventing:
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh
	INSTALL_SERVING="false" ./hack/install.sh

install-kafka:
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh
	SCALE_UP=4 INSTALL_SERVING="false" INSTALL_KAFKA="true" ./hack/install.sh

install-kafka-with-mesh:
	FULL_MESH="true" UNINSTALL_MESH="false" ./hack/mesh.sh
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh
	TRACING_BACKEND=zipkin TRACING_NAMESPACE=knative-eventing ./hack/tracing.sh
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	FULL_MESH=true SCALE_UP=5 INSTALL_SERVING=false INSTALL_EVENTING=true INSTALL_KAFKA=true TRACING_BACKEND=zipkin TRACING_NAMESPACE=knative-eventing ENABLE_TRACING=true ./hack/install.sh

install-kafka-with-keda:
	UNINSTALL_KEDA="false" ./hack/keda.sh
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh
	SCALE_UP=4 INSTALL_SERVING="false" INSTALL_KAFKA="true" ENABLE_KEDA="true" ./hack/install.sh

install-strimzi:
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh

uninstall-strimzi:
	UNINSTALL_STRIMZI="true" ./hack/strimzi.sh

install-keda:
	UNINSTALL_KEDA="false" ./hack/keda.sh

uninstall-keda:
	UNINSTALL_KEDA="true" ./hack/keda.sh

install-certmanager:
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh

uninstall-certmanager:
	UNINSTALL_CERTMANAGER="true" ./hack/certmanager.sh

install-previous:
	INSTALL_PREVIOUS_VERSION="true" ./hack/install.sh

install-previous-with-kafka:
	INSTALL_PREVIOUS_VERSION="true" INSTALL_KAFKA="true" ./hack/install.sh

install-mesh:
	UNINSTALL_MESH="false" ./hack/mesh.sh

uninstall-mesh:
	UNINSTALL_MESH="true" ./hack/mesh.sh

install-full-mesh:
	FULL_MESH="true" UNINSTALL_MESH="false" ./hack/mesh.sh

uninstall-full-mesh:
	FULL_MESH="true" UNINSTALL_MESH="true" ./hack/mesh.sh

install-with-mesh-enabled:
	FULL_MESH=true ./hack/install.sh

install-tracing-zipkin:
	TRACING_BACKEND=zipkin ./hack/tracing.sh

uninstall-tracing-zipkin:
	UNINSTALL_TRACING=true TRACING_BACKEND=zipkin ./hack/tracing.sh

install-tracing-opentelemetry:
	./hack/tracing.sh

uninstall-tracing-opentelemetry:
	UNINSTALL_TRACING=true ./hack/tracing.sh

install-cluster-logging:
	./hack/clusterlogging.sh

teardown:
	./hack/teardown.sh

# Test targets for CI operator.
test-unit:
	go test ./knative-operator/...
	go test ./openshift-knative-operator/...
	go test ./serving/ingress/...
	go test ./serving/metadata-webhook/...

# Run only SERVING/EVENTING E2E tests from the current repo.
test-e2e-testonly:
	./test/e2e-tests.sh

test-e2e:
	./hack/tracing.sh
	ENABLE_TRACING=true ./hack/install.sh
	./test/e2e-tests.sh
	DELETE_CRD_ON_TEARDOWN="false" ./hack/teardown.sh

# Run E2E tests from the current repo for serving+eventing+knativeKafka
test-e2e-with-kafka-testonly:
	TEST_KNATIVE_KAFKA=true ./test/e2e-tests.sh

operator-e2e:
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	./hack/tracing.sh
	SCALE_UP=4 INSTALL_KAFKA="true" ENABLE_TRACING=true ./hack/install.sh
	TEST_KNATIVE_KAFKA=true ./test/e2e-tests.sh
	DELETE_CRD_ON_TEARDOWN="false" ./hack/teardown.sh

test-e2e-with-kafka: operator-e2e

# Run E2E tests from the current repo for serving+eventing+mesh
test-e2e-with-mesh-testonly:
	FULL_MESH=true ./test/e2e-tests.sh

test-e2e-with-mesh:
	FULL_MESH="true" UNINSTALL_MESH="false" ./hack/mesh.sh
	./hack/tracing.sh
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	FULL_MESH=true SCALE_UP=4 INSTALL_KAFKA="true" ENABLE_TRACING=true ./hack/install.sh
	FULL_MESH=true TEST_KNATIVE_KAFKA=true ./test/e2e-tests.sh

# Run both unit and E2E tests from the current repo.
test-operator: test-unit test-e2e

# Run upstream E2E tests with net-istio and sidecar.
# TODO: Enable upgrade tests once upstream fixed the issue https://github.com/knative/serving/issues/11535.
test-upstream-e2e-mesh-testonly:
	FULL_MESH=true TEST_KNATIVE_KAFKA=true ./test/e2e-tests.sh
	FULL_MESH=true TEST_KNATIVE_KAFKA=false TEST_KNATIVE_SERVING=true TEST_KNATIVE_EVENTING=true TEST_KNATIVE_KAFKA_BROKER=true TEST_KNATIVE_UPGRADE=false ./test/upstream-e2e-tests.sh

mesh-e2e:
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh # This avoids early failures for the skipped Eventing TLS tests
	FULL_MESH="true" UNINSTALL_MESH="false" ./hack/mesh.sh
	TRACING_BACKEND=zipkin TRACING_NAMESPACE=knative-eventing ./hack/tracing.sh
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	FULL_MESH=true SCALE_UP=6 INSTALL_SERVING=true INSTALL_EVENTING=true INSTALL_KAFKA=true TRACING_BACKEND=zipkin TRACING_NAMESPACE=knative-eventing ENABLE_TRACING=true ./hack/install.sh
	FULL_MESH=true TEST_KNATIVE_KAFKA=true ./test/e2e-tests.sh
	FULL_MESH=true TEST_KNATIVE_KAFKA=false TEST_KNATIVE_SERVING=true TEST_KNATIVE_EVENTING=true TEST_KNATIVE_KAFKA_BROKER=true TEST_KNATIVE_UPGRADE=false ./test/upstream-e2e-tests.sh

test-upstream-e2e-mesh: mesh-e2e

# Run upstream E2E tests without upgrades.
test-upstream-e2e-no-upgrade-testonly:
	FULL_MESH=true ./test/e2e-tests.sh
	FULL_MESH=true TEST_KNATIVE_SERVING=true TEST_KNATIVE_EVENTING=true TEST_KNATIVE_KAFKA_BROKER=true TEST_KNATIVE_UPGRADE=false ./test/upstream-e2e-tests.sh

test-upstream-e2e-kafka-no-upgrade-testonly:
	TEST_KNATIVE_KAFKA_BROKER=true TEST_KNATIVE_E2E=true TEST_KNATIVE_UPGRADE=false ./test/upstream-e2e-tests.sh

upstream-e2e:
	TRACING_BACKEND=zipkin ./hack/tracing.sh
	TRACING_BACKEND=zipkin ENABLE_TRACING=true ./hack/install.sh
	TEST_KNATIVE_KAFKA=false TEST_KNATIVE_E2E=true TEST_KNATIVE_SERVING=true TEST_KNATIVE_EVENTING=true TEST_KNATIVE_UPGRADE=false ./test/upstream-e2e-tests.sh

test-upstream-e2e-no-upgrade: upstream-e2e

upstream-e2e-kafka:
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	UNINSTALL_CERTMANAGER="false" ./hack/certmanager.sh
	TRACING_BACKEND=zipkin ./hack/tracing.sh
	SCALE_UP=5 INSTALL_KAFKA="true" TRACING_BACKEND=zipkin ENABLE_TRACING=true ./hack/install.sh
	TEST_KNATIVE_KAFKA_BROKER=true TEST_KNATIVE_E2E=true TEST_KNATIVE_UPGRADE=false ./test/upstream-e2e-tests.sh

test-upstream-e2e-kafka-no-upgrade: upstream-e2e-kafka

# Run only upstream upgrade tests.
test-upstream-upgrade-testonly:
	TEST_KNATIVE_KAFKA=true TEST_KNATIVE_E2E=false TEST_KNATIVE_UPGRADE=true ./test/upstream-e2e-tests.sh

test-upgrade:
	TRACING_BACKEND=zipkin ZIPKIN_DEDICATED_NODE=true ./hack/tracing.sh
	UNINSTALL_STRIMZI=false ./hack/strimzi.sh
	INSTALL_PREVIOUS_VERSION=true INSTALL_KAFKA=true TRACING_BACKEND=zipkin ENABLE_TRACING=true SCALE_UP=5 ./hack/install.sh
	TEST_KNATIVE_KAFKA=true TEST_KNATIVE_E2E=false TEST_KNATIVE_UPGRADE=true ./test/upstream-e2e-tests.sh

mesh-upgrade:
	FULL_MESH=true UNINSTALL_MESH=false ./hack/mesh.sh
	TRACING_BACKEND=zipkin ./hack/tracing.sh
	UNINSTALL_STRIMZI=false ./hack/strimzi.sh
	FULL_MESH=true INSTALL_PREVIOUS_VERSION=true INSTALL_KAFKA=true TRACING_BACKEND=zipkin ENABLE_TRACING=true SCALE_UP=5 ./hack/install.sh
	FULL_MESH=true TEST_KNATIVE_KAFKA=true TEST_KNATIVE_E2E=false TEST_KNATIVE_UPGRADE=true ./test/upstream-e2e-tests.sh

test-upgrade-with-mesh: mesh-upgrade

kitchensink-upgrade:
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	./hack/dev.sh
	INSTALL_OLDEST_COMPATIBLE="true" INSTALL_KAFKA="true" SCALE_UP=4 ./hack/install.sh
	./test/kitchensink-upgrade-tests.sh

test-kitchensink-upgrade: kitchensink-upgrade

test-kitchensink-upgrade-testonly:
	./test/kitchensink-upgrade-tests.sh

test-kitchensink-upgrade-stress:
	UNINSTALL_STRIMZI=false ./hack/strimzi.sh
	INSTALL_PREVIOUS_VERSION=true INSTALL_KAFKA=true SCALE_UP=5 ./hack/install.sh
	./test/kitchensink-upgrade-stress-tests.sh

test-kitchensink-upgrade-stress-testonly:
	./test/kitchensink-upgrade-stress-tests.sh

# Run Console UI e2e tests.
test-ui-e2e-testonly:
	./test/ui-e2e-tests.sh

ui-e2e:
	./hack/install.sh
	./test/ui-e2e-tests.sh

test-ui-e2e: ui-e2e

# Run only kitchensink e2e tests
test-kitchensink-e2e-testonly:
	./test/kitchensink-e2e-tests.sh

# Run only a subset of e2e tests, e.g. "make test-kitchensink-e2e-single-testonly TEST=TestBroker"
test-kitchensink-e2e-single-testonly:
	./test/kitchensink-e2e-tests.sh -run $(TEST)

test-kitchensink-e2e-setup:
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	SCALE_UP=4 INSTALL_KAFKA="true" ./hack/install.sh

# Runs all subsets of kitchensink tests. Runs tests separately so `go test` doesn't take too much memory in CI
kitchensink-e2e:
	UNINSTALL_STRIMZI="false" ./hack/strimzi.sh
	SCALE_UP=4 INSTALL_KAFKA="true" ./hack/install.sh
	./test/kitchensink-e2e-tests.sh -run TestBrokerReadinessBrokerDLS
	./test/kitchensink-e2e-tests.sh -run TestBrokerReadinessTriggerDLS
	./test/kitchensink-e2e-tests.sh -run TestChannelReadiness
	./test/kitchensink-e2e-tests.sh -run TestFlowReadiness
	./test/kitchensink-e2e-tests.sh -run TestSourceReadiness

test-kitchensink-e2e: kitchensink-e2e

# Run all E2E tests.
test-all-e2e:
	./hack/tracing.sh
	ENABLE_TRACING=true ./hack/install.sh
	./test/e2e-tests.sh
	TEST_KNATIVE_KAFKA=true TEST_KNATIVE_E2E=true TEST_KNATIVE_UPGRADE=false ./test/upstream-e2e-tests.sh
	TEST_KNATIVE_KAFKA=true TEST_KNATIVE_E2E=false TEST_KNATIVE_UPGRADE=true ./test/upstream-e2e-tests.sh
	./test/ui-e2e-tests.sh
	DELETE_CRD_ON_TEARDOWN="false" ./hack/teardown.sh

# Generates a ci-operator configuration for a specific branch.
generate-ci-config:
	./openshift/ci-operator/generate-ci-config.sh $(BRANCH) > ci-operator-config.yaml

# Generates all files that are templated with release metadata.
release-files:
	./hack/generate/csv.sh \
		templates/csv.yaml \
		olm-catalog/serverless-operator/manifests/serverless-operator.clusterserviceversion.yaml
	./hack/generate/annotations.sh \
		templates/annotations.yaml \
		olm-catalog/serverless-operator/metadata/annotations.yaml
	./hack/generate/dockerfile.sh \
		templates/knative-operator.Dockerfile \
		knative-operator/Dockerfile
	./hack/generate/dockerfile.sh \
		templates/openshift-knative-operator.Dockerfile \
		openshift-knative-operator/Dockerfile
	./hack/generate/dockerfile.sh \
		templates/serving-ingress.Dockerfile \
		serving/ingress/Dockerfile
	./hack/generate/dockerfile.sh \
		templates/serving-metadata-webhook.Dockerfile \
		serving/metadata-webhook/Dockerfile
	./hack/generate/dockerfile.sh \
		templates/main.Dockerfile \
		olm-catalog/serverless-operator/Dockerfile
	./hack/generate/dockerfile.sh \
		templates/test-source-image.Dockerfile \
		openshift/ci-operator/source-image/Dockerfile
	./hack/generate/dockerfile.sh \
		templates/build-image.Dockerfile \
		openshift/ci-operator/build-image/Dockerfile
	./hack/generate/dockerfile.sh \
 		templates/index.Dockerfile \
		olm-catalog/serverless-operator/index/Dockerfile
	./hack/generate/index.sh \
		templates/index.yaml \
		olm-catalog/serverless-operator/index/configs/index.yaml
	./hack/generate/quickstart.sh \
		templates/serverless-application-quickstart.yaml \
		knative-operator/deploy/resources/quickstart/serverless-application-quickstart.yaml
	./hack/generate/images-rekt.sh \
		templates/images-rekt.yaml \
		test/images-rekt.yaml
	./hack/generate/mesh-auth-policies.sh \
  	tenant-1,tenant-2,serving-tests,serverless-tests,eventing-e2e0,eventing-e2e1,eventing-e2e2,eventing-e2e3,eventing-e2e4

# Generates all files that can be generated, includes release files, code generation
# and updates vendoring.
# Use CURRENT_VERSION_IMAGES="<branch>" if you need to override the defaulting to main
generated-files: release-files
	./hack/update-deps.sh
	./hack/update-codegen.sh
	(cd knative-operator && ./hack/update-manifests.sh)
	(cd openshift-knative-operator && ./hack/update-manifests.sh)
	(cd olm-catalog/serverless-operator && ./hack/update-manifests.sh)
	./hack/update-deps.sh

# Runs the lints Github Actions do too.
lint:
	woke
	golangci-lint run
	find . -type f -path './**/*.*sh' -not -path '*vendor*' | xargs -r shellcheck
	operator-sdk bundle validate ./olm-catalog/serverless-operator --select-optional suite=operatorframework --optional-values=k8s-version=1.22
	git ls-files | grep -Ev '^(vendor/|.git)' | xargs misspell -i importas -error
	prettier -c templates/*.yaml

# Runs formatters and thelike to fix potential linter warnings.
fix-lint:
	prettier --write templates/*.yaml
