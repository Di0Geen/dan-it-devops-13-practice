# Homework 24: Kubernetes Deployment and Service

У цій домашній роботі було створено Docker-образ із Python-скриптом, який повертає випадковий рядок. Образ завантажено у приватний репозиторій Docker Hub.

У локальному Kubernetes-кластері створено Deployment із трьома подами та Service типу NodePort. Під час перевірки Service розподіляв запити між різними подами.

Docker-образ:

di0geen/homework24:1.0

## Виконано

- створено Dockerfile для Python-скрипту;
- створено та перевірено Docker-образ;
- образ завантажено у приватний Docker Hub репозиторій;
- створено локальний кластер Minikube;
- створено Deployment із трьома репліками;
- додано доступ до приватного образу через Kubernetes Secret;
- створено Service типу NodePort;
- виконано запити до Service;
- перевірено розподілення трафіку між трьома подами.

## Використані інструменти

- Python
- Docker Desktop
- Docker Hub
- Minikube
- Kubernetes
- kubectl
- Visual Studio Code

## Структура проєкту

Homework24/
├── Src/
│   ├── create-cluster.sh
│   ├── Dockerfile
│   ├── python-random.py
│   ├── deployment.yaml
│   └── service.yaml
├── Screens/
├── .gitignore
└── README.md
