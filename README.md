# ArgoCD Installation Guide

## About

This repository contains instructions and configuration for installing ArgoCD, a declarative GitOps continuous delivery tool for EKS.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Accessing ArgoCD UI](#accessing-argocd-ui)
- [Create An ArgoCD Application](#installation)
- [🔧Troubleshooting](#troubleshooting)
- [Resources](#resources)

## Prerequisites

Before installing ArgoCD, ensure you have:

- A running Kubernetes cluster (v1.21 or later)
- `kubectl` installed and configured to communicate with your cluster
- Sufficient permissions to create namespaces and deploy resources

## Installation

### 1. Install ArgoCD With Helm Chart
The script will install argo cd helm chart on your EKS cluster
```bash

sh argocd-bootstrap.sh
```
Note the password shown as output after running the script

## Accessing ArgoCD UI

- As specified in argocd-values.yaml that's passed while installing argocd through helm
a loadBalancer is created for the ArgoCD dashboard. 
- Open AWS dashboard and get
the public DNS of the load balancer.
- Login using the username: admin and password in the step above

(https://github.com/mona861/argocd-eks-deployment/blob/main/doc/screenshots/argo-dashboard.png)

## Create An ArgoCD Application
The ArgoCD application will link your repo to ArgoCD gitops.
The application can be created directly through the dashboard or
using a yaml file. To create through the yaml run
```bash
kubectl apply -f  argocd-application.yaml
```

## 🔧Troubleshooting

### Issue: CustomResourceDefinition Annotation Too Long
<details>

**Error Message:**
```
The CustomResourceDefinition "applicationsets.argoproj.io" is invalid: 
metadata.annotations: Too long: may not be more than 262144 bytes
```

**Description:**

This error occurs when applying ArgoCD manifests with CustomResourceDefinitions (CRDs) that contain annotations exceeding Kubernetes' size limit of 262144 bytes (256 KB). This commonly happens with CRDs that have large OpenAPI schemas stored in annotations.

**Root Cause:**

The ArgoCD ApplicationSet CRD includes extensive OpenAPI validation schemas that, when converted to annotations by certain tools (like `kubectl apply`), can exceed the annotation size limit.

**Resolution:**

Install Argo CD using HELM

</details>

## Resources

- [Official ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD GitHub Repository](https://github.com/argoproj/argo-cd)
- [ArgoCD Getting Started Guide](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)

