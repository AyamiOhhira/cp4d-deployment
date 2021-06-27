#!/bin/bash

APIKEY=$1
OPT_NAMESPACE=$2
EXTERNAL_CPD_REGISTRY=$3
EXTERNAL_CPD_USER=$4

if [[ $EXTERNAL_CPD_REGISTRY == "" ]]; then
export CPD_REGISTRY=cp.icr.io/cp/cpd
export CPD_REGISTRY_USER=cp
else
export CPD_REGISTRY_USER=$EXTERNAL_CPD_USER
export CPD_REGISTRY=$EXTERNAL_CPD_REGISTRY
oc create secret generic external-cpd-registry --from-literal=url="$EXTERNAL_CPD_REGISTRY" --from-literal=user="$EXTERNAL_CPD_USER" --from-literal=key="${APIKEY}" -n $OPT_NAMESPACE
fi
export CPD_REGISTRY_PASSWORD=$APIKEY
export NAMESPACE=$OPT_NAMESPACE

case $(uname -s) in
  Linux)
    ./cloudctl-linux-amd64 case launch            \
        --case ibm-cp-datacore                    \
        --namespace ${OPT_NAMESPACE}              \
        --inventory cpdMetaOperatorSetup          \
        --action install-operator                 \
        --tolerance=1                             \
        --args "--entitledRegistry ${CPD_REGISTRY} --entitledUser ${CPD_REGISTRY_USER} --entitledPass ${APIKEY}"
    ;;
  Darwin)
    ./cloudctl-darwin-amd64 case launch           \
        --case ibm-cp-datacore                    \
        --namespace ${OPT_NAMESPACE}              \
        --inventory cpdMetaOperatorSetup          \
        --action install-operator                 \
        --tolerance=1                             \
        --args "--entitledRegistry ${CPD_REGISTRY} --entitledUser ${CPD_REGISTRY_USER} --entitledPass ${APIKEY}"
    ;;
  *)
    echo 'Supports only Linux and Mac OS at this time'
    exit 1;;
esac