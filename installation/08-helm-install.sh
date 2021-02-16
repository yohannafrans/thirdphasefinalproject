# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install helm repositories, so we can search the stable charts through this
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add elastic https://helm.elastic.co
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add dikacloud http://34.97.149.48:8088/
helm repo add fluent https://fluent.github.io/helm-charts