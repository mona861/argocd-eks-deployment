
<details>
<summary>📦 Click here for installation instructions</summary>

#### Install kubectl
```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### Install Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

</details>

## 📁 Project Structure
```
eks-cluster-terraform/
│
├── k8s-manifests/                 # Kubernetes manifests
│   ├── base/                      # Base resources
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── serviceaccount.yaml
│   │   ├── secretstore.yaml
│   │   └── externalsecret.yaml
│   │
│   ├── common/                    # Shared Kustomize component
│   │   └── kustomization.yaml     # Common transformations
│   │
│   └── overlays/                  # Environment-specific configs
│       ├── dev/
│       │   └── kustomization.yaml
```
## 📦 Deployment Steps
#### Step 1: Add a new environment
- In overlays create a new folder and copy eks-cluster-terraform/k8s-manifests/overlays/kustomization.yaml
- In kustomization.yaml
    - Set namePrefix:  
        - <span style="color:orange">**[[ENV]]-**</span>
    - Set EKS_POD_IDENTITY_IAM_ROLE:  
        - **<span style="color:green">arn:aws:iam::<span style="color:purple">[[AWS_ACCOUNT_ID]]</span>:role/<span style="color:orange">[[ENV]]</span>-demo-eks-pod_role</span>**
    - Note:
        - Replace <span style="color:orange">**[[ENV]]**</span> with your target env
        - Replace <span style="color:purple">**[[AWS_ACCOUNT_ID]]**</span> with your AWS_ACCOUNT_ID

#### Step 2: Configure kubectl Access

```bash
# Update kubeconfig to access the cluster
aws eks update-kubeconfig --region us-east-1 --name demo-eks-cluster

# Verify cluster access
kubectl get nodes
```

#### Step 3: Apply kubectl manifests

```bash
cd ../k8s-manifests

# Deploy ServiceAccount, SecretStore, and ExternalSecrets
kubectl apply -k overlays/dev/
```
