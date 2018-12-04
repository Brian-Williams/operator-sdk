FROM docker:18-git

# Branch to checkout to install
ARG BRANCH=master
ENV KUBE_LATEST_VERSION="v1.12.3"
ENV GOPATH="$HOME/go"

# "dep>5.0" fails...
#       fetch http://dl-cdn.alpinelinux.org/alpine/v3.8/main/x86_64/APKINDEX.tar.gz
#       fetch http://dl-cdn.alpinelinux.org/alpine/v3.8/community/x86_64/APKINDEX.tar.gz
#       ERROR: unsatisfiable constraints:
#       dep-0.4.1-r0:
#       breaks: world[dep>0.5]
RUN apk add --update curl && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    apk add dep go make libc-dev && \
    mkdir -p $GOPATH/src/github.com/operator-framework && \
    cd $GOPATH/src/github.com/operator-framework && \
    git clone https://github.com/operator-framework/operator-sdk && \
    cd operator-sdk && \
    git checkout ${BRANCH} && \
    make dep
# Fails:
#   loadinternal: cannot find runtime/cgo
RUN cd $GOPATH/src/github.com/operator-framework && \
    make install V=1
