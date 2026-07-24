#!/bin/bash

set -e

minikube start --driver=docker
kubectl get nodes