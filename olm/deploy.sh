#!/bin/sh

printf "%50s: %s\n" OLM_BAD_NODES "${OLM_BAD_NODES:=}"

cd "$(dirname "$0")"

echo "Deploying OLM CRDs"
kubectl apply -k crds
echo "waiting for crd/catalogsource to become ready for use"
kubectl wait crd/catalogsources.operators.coreos.com --for=condition=established
for f in $OLM_BAD_NODES;do
  kubectl cordon "$f"
done
echo "Deploying OLM"
kubectl apply -k .
echo "waiting for olm.deployment/olm-operator to become available"
kubectl wait deployment -n olm olm-operator --for=condition=available
