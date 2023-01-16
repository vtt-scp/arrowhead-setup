#!/bin/bash

source "./scripts/lib_certs.sh"
export PASSWORD=$3

# Running this script does not replace existing certificates

ROOT="arrowhead.eu"
# Relay system name
RELAY_NAME=$1
# Append relay dns and/or ip address to RELAY_SAN
RELAY_SAN=$2

# RELAY
# Relay certificates for relay systems between Arrowhead local clouds

create_relay_system_keystore() {
  SYSTEM_NAME=$1
  SAN="dns:${SYSTEM_NAME//_}"

  create_system_keystore \
    "./certs/master/master.p12" "${ROOT}" \
    "./certs/relay/relay.p12" "relay.${ROOT}" \
    "./certs/relay/${SYSTEM_NAME}.p12" "${SYSTEM_NAME}.relay.${ROOT}" \
    "${SAN},${RELAY_SAN}"
}

create_relay_system_keystore "${RELAY_NAME}"