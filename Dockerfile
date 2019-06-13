FROM golang:1.12

RUN mkdir /reports && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y rsync ca-certificates ca-cacert && \
    mkdir -p /go/src/k8s.io && \
    git clone https://github.com/kubernetes/kubernetes.git /go/src/k8s.io/kubernetes

RUN cd /go/src/k8s.io/kubernetes && git checkout refs/tags/v1.10.13

WORKDIR /go/src/k8s.io/kubernetes

RUN make all WHAT=cmd/kubectl && \
    make all WHAT=vendor/github.com/onsi/ginkgo/ginkgo && \
    make all WHAT=test/e2e/e2e.test

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh