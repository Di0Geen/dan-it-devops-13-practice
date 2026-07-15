#!/bin/bash

set -e

echo "Створення локального Kubernetes-кластера..."

minikube start --driver=docker

echo "Перевірка стану кластера..."

minikube status
kubectl get nodes
kubectl cluster-info