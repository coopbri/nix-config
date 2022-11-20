#!/bin/sh
# ! run as sudo

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

helm repo add cilium https://helm.cilium.io

# unsure if ipam.mode or image.pullPolicy are required
# TODO dynamic hostname
helm upgrade --force --install cilium cilium/cilium --version 1.12.4 --namespace kube-system --set operator.replicas=1 --set image.pullPolicy="IfNotPresent" --set ipam.mode="kubernetes" --set kubeProxyReplacement="strict" --set-string=k8sServiceHost=snowflake,k8sServicePort=6443 --set hubble.relay.enabled=true --set hubble.ui.enabled=true
