# 1. Add the repo
helm repo add argoproj https://argoproj.github.io/argo-helm

# 2. Update the repo index (fetches the latest chart versions)
helm repo update

# 3. Now run your install
helm install argocd argoproj/argo-cd \
  --namespace argocd \
  --create-namespace \
  -f argocd-values.yaml

# To upgrade later (e.g. new chart version or values change):
helm upgrade argocd argoproj/argo-cd \
  --namespace argocd \
  -f argocd-values.yaml
  
pwd=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")
echo $pwd | base64 -d
