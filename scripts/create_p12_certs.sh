#!/bin/bash

# Original created by Emanuel Palm (https://github.com/emanuelpalm)
# Edited by Jani Hietala (https://github.com/scurvide)

source "./scripts/lib_certs.sh"

# Running this script does not replace any existing certificates
# Only creates new ones and adds them to truststore

ROOT="arrowhead.eu"
# Your company
COMPANY=$1
# Your Arrowhead cloud
CLOUD=$2
# Relay
RELAY=$3
# Append Arrowhead cloud dns and/or ip address to COMMON_SAN
COMMON_SAN=$4


# ROOT

# If you want to start the certificate chain from an existing master
# certificate, add the certificate file to this path and name below
create_root_keystore \
  "./certs/master/master.p12" "${ROOT}"


# CLOUD

# If you want to use an existing cloud certificate, add the
# certificate file to this path and name below
create_cloud_keystore \
  "./certs/master/master.p12" "${ROOT}" \
  "./certs/cloud/${CLOUD}.p12" "${CLOUD}.${COMPANY}.${ROOT}"


# RELAY

# Relay certificates for the relay system between Arrowhead local clouds
create_cloud_keystore \
  "./certs/master/master.p12" "${ROOT}" \
  "./certs/relay/${RELAY}.p12" "${RELAY}.${ROOT}"

create_relay_system_keystore() {
  SYSTEM_NAME=$1
  SAN="dns:${SYSTEM_NAME//_}"

  create_system_keystore \
    "./certs/master/master.p12" "${ROOT}" \
    "./certs/relay/${RELAY}.p12" "${RELAY}.${ROOT}" \
    "./certs/relay/${SYSTEM_NAME}.p12" "${SYSTEM_NAME}.${RELAY}.${ROOT}" \
    "${SAN},${COMMON_SAN}"
}
create_relay_system_keystore "your_relay"

create_truststore \
  "./certs/relay/truststore.p12" \
  "./certs/master/master.crt" "${ROOT}"


# ARROWHEAD CORE

create_consumer_system_keystore() {
  SYSTEM_NAME=$1
  SAN="dns:${SYSTEM_NAME//_}"

  create_system_keystore \
    "./certs/master/master.p12" "${ROOT}" \
    "./certs/cloud/${CLOUD}.p12" "${CLOUD}.${COMPANY}.${ROOT}" \
    "./certs/${SYSTEM_NAME}.p12" "${SYSTEM_NAME}.${CLOUD}.${COMPANY}.${ROOT}" \
    "${SAN},${COMMON_SAN}"
}

# Arrowhead core service certs
create_consumer_system_keystore "authorization"
create_consumer_system_keystore "orchestrator"
create_consumer_system_keystore "serviceregistry"
create_consumer_system_keystore "gatekeeper"
create_consumer_system_keystore "gateway"
create_consumer_system_keystore "certificateauthority"
create_consumer_system_keystore "eventhandler"


# SYSOP

# Sysop certificates for system management
create_sysop_keystore \
  "./certs/master/master.p12" "${ROOT}" \
  "./certs/cloud/${CLOUD}.p12" "${CLOUD}.${COMPANY}.${ROOT}" \
  "./certs/sysop.p12" "sysop.${CLOUD}.${COMPANY}.${ROOT}"


# TRUSTSTORE

# Truststores for Arrowhead core services
create_truststore \
  "./certs/truststore.p12" \
  "./certs/cloud/${CLOUD}.crt" "${CLOUD}.${COMPANY}.${ROOT}"

# Truststore for gatekeeper and gateway including relay master certificate
create_truststore \
  "./certs/gk_gw_truststore.p12" \
  "./certs/cloud/${CLOUD}.crt" "${CLOUD}.${COMPANY}.${ROOT}" \
  "./certs/relay/${RELAY}.crt" "${RELAY}.${ROOT}"