#!/bin/bash

helm uninstall --namespace=loki loki
kubectl delete secret generic iam-loki-s3
kubectl delete all --all -n loki
kubectl delete ns loki

