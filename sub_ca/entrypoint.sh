#!/bin/bash

source /usr/local/bin/utils

default_csr="/usr/local/share/default-csr.json"
default_ca_csr="/usr/local/share/default-ca-csr.json"

if [[ ! -f rootca.pem ]]; then


    cfssl gencert -initca \
        -cn="se23-root-ca" \
        "${default_ca_csr}" | cfssljson -bare root-ca -
    rm -f root-ca.csr
    ln -s root-ca.pem ca-bundle.crt

    ln -s root-ca.pem ca.pem
    ln -s root-ca-key.pem ca-key.pem
fi

args=()
args+=( "-ca" "ca.pem" )
args+=( "-ca-key" "ca-key.pem" )
args+=( "-ca-bundle" "ca-bundle.crt" )
args+=( "-config" "config.json" )
args+=( "-db-config" "db-config.json" )

if [[ ! -f sub-ca.pem ]]; then

    cfssl gencert \
        "${args[@]}" \
        -profile=subordinate \
        -cn="se23-sub-ca" \
        -hostname="root_ca, rootca.sez23.net, 127.0.0.1, localhost" \
        "${default_csr}" | cfssljson -bare sub-ca -
    rm -f sub-ca.csr

    rm -f sub-ca.csr ca.pem ca-key.pem
    ln -s sub-ca.pem ca.pem
    ln -s sub-ca-key.pem ca-key.pem
fi


if [[ ! -f tls.pem ]]; then


    cfssl gencert \
        "${args[@]}" \
        -profile=server \
        -cn="se23-sub-ca-tls" \
        -hostname="root_ca, rootca.sez23.net, 127.0.0.1, localhost" \
        "${default_csr}" | cfssljson -bare tls -

    rm -f tls.csr
fi

cfssl serve "${args[@]}" \
    -address=0.0.0.0 \
    -port=8888 \
    -tls-cert=tls.pem \
    -tls-key=tls-key.pem \
    -ca-bundle=ca-bundle.crt \
    -loglevel=0
