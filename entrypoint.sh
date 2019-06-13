#!/bin/bash

set -u -e

function escape_test_name() {
    sed 's/[]\$*.^|()[]/\\&/g; s/\s\+/\\s+/g' <<< "$1" | tr -d '\n'
}

TESTS_TO_SKIP=(
     '[k8s.io] Networking should provide unchanging, static URL paths for kubernetes api services [Conformance]'
     '[k8s.io] SchedulerPredicates [Serial] validates that NodeSelector is respected if not matching [Conformance]'
     '[k8s.io] SchedulerPredicates [Serial] validates resource limits of pods that are allowed to run [Conformance]'
     '[k8s.io] SchedulerPredicates [Serial] validates that NodeSelector is respected if matching [Conformance]'
)

function skipped_test_names () {
    local first=y
    for name in "${TESTS_TO_SKIP[@]}"; do
        if [ -z "${first}" ]; then
            echo -n "|"
        else
            first=
        fi
        echo -n "$(escape_test_name "${name}")\$"
    done
}


KUBERNETES_PROVIDER=${KUBERNETES_PROVIDER:-"skeleton"}
KUBERNETES_CONFORMANCE_TEST=${KUBERNETES_CONFORMANCE_TEST:-true}
API_SERVER=${API_SERVER:-'http://localhost:8080'}
PROXY_SERVER=${PROXY_SERVER:-'http://10.252.2.222:1081'}
E2E_REPORT_DIR=${E2E_REPORT_DIR:-/var/log}
export KUBERNETES_PROVIDER=${KUBERNETES_PROVIDER}
export KUBERNETES_CONFORMANCE_TEST=${KUBERNETES_CONFORMANCE_TEST}
export E2E_REPORT_DIR=${E2E_REPORT_DIR}




if [ -z "${API_SERVER}" ]; then
    echo "Must provide API_SERVER env var" 1>&2
    exit 1
fi

if [ ! -z "${PROXY_SERVER}" ]; then
    export http_proxy=${PROXY_SERVER}
    export https_proxy=${PROXY_SERVER}
fi

# Configure kube config
cluster/kubectl.sh config set-cluster local --server="${API_SERVER}" --insecure-skip-tls-verify=true
cluster/kubectl.sh config set-context local --cluster=local --user=local
cluster/kubectl.sh config use-context local

num_nodes="$(cluster/kubectl.sh get nodes -o name|wc -l)"

echo "tests:"
GINKGO_PARALLEL_NODES="$num_nodes" GINKGO_PARALLEL=y go run hack/e2e.go --get=false -- --test --provider=${KUBERNETES_PROVIDER} --check-version-skew=false --test_args="--ginkgo.focus=\[Conformance\] --ginkgo.skip=\[Serial\]|\[Flaky\]|\[Feature:.+\]" | tee -a ${E2E_REPORT_DIR}/e2e_conformance-"$(date +%Y-%m-%d)".log
