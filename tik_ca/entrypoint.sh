#!/bin/bash

source /usr/local/bin/utils

default_csr="/usr/local/share/default-csr.json"
default_ca_csr="/usr/local/share/default-ca-csr.json"

args=()

export CFSSL_CA_CERT="ca.pem"
export CFSSL_CA_KEY="ca-key.pem"
export CFSSL_CONFIG="config.json"
export CFSSL_DB_CONFIG="db-config.json"
export CFSSL_PROFILE="server"


function gen-cert
{
    cert="${1}"
    shift
    cn="${2}"
    shift
    
    [[ -f "${cert}.pem" ]] && exit 1

    args=()
    [[ -f "${CFSSL_CA_CERT}" ]] && args+=("-ca=${CFSSL_CA_CERT}")
    [[ -f "${CFSSL_CA_KEY}" ]] && args+=("-ca-key=${CFSSL_CA_KEY}")
    [[ -f "${CFSSL_CONFIG}" ]] && args+=("-config=${CFSSL_CONFIG}")
    [[ -f "${CFSSL_DB_CONFIG}" ]] && args+=("-db-config=${CFSSL_DB_CONFIG}")

    [ "${CFSSL_HOSTS:-}" ] && args+=("-hostname=${CFSSL_HOSTS}")
    [ "${CFSSL_PROFILE:-}" ] && args+=("-profile=${CFSSL_PROFILE}")
    [ "${cn:-}" ] && args+=("-cn=${cn}")

    args+=("${@}")

    cfssl gencert \
        "${args[@]}" \
        "${default_csr}" | cfssljson -bare "${cert}" -

    rm -f "${cert}.csr"
}

cp /etc/cfssl/root_ca/sub-ca.pem .
cp /etc/cfssl/root_ca/root-ca.pem .

unset CFSSL_CA_CERT
unset CFSSL_CA_KEY
export CFSSL_CONFIG="config/config-remote.json"
export CFSSL_HOSTS="tik_ca, tikca.sez23.net, 127.0.0.1, localhost"
gen-cert "ca" "se23-tik-ca" -tls-remote-ca="sub-ca.pem" -loglevel=0

export CFSSL_CA_CERT="ca.pem"
export CFSSL_CA_KEY="ca-key.pem"
export CFSSL_CONFIG="config/config.json"
export CFSSL_DB_CONFIG="db-config.json"
export CFSSL_PROFILE="server"
gen-cert "tls" "se23-tik-ca-tls" 

export CFSSL_PROFILE="signer"
gen-cert "ovpn" "se23-ovpn-ca" 
gen-cert "capsman" "se23-capsmanr-ca" 
gen-cert "cli" "sr23-cli-ca" 

multirootca \
    -a="0.0.0.0:8888" \
    -roots=roots.ini \
    -tls-cert=tls.pem \
    -tls-key=tls-key.pem

exit 1

