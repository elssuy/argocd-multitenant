#!/bin/bash


pulumi stack output  --show-secrets -j | jq ".clusterKubeconfig.admin[0].configFile" -r > .cluster-admino

for i in {1..3}
do
  CA=$(pulumi stack output --show-secrets -j | jq ".clusterKubeconfig.c$i[0].clusterCaCertificate" -r)
  HOST=$(pulumi stack output --show-secrets -j | jq ".clusterKubeconfig.c$i[0].host" -r)
  TOKEN=$(pulumi stack output --show-secrets -j | jq ".clusterKubeconfig.c$i[0].token" -r)

  echo -e "HOST: $HOST \t TOKEN: $TOKEN"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  labels:
    argocd.argoproj.io/secret-type: cluster
  namespace: argocd
  name: cluster-$i
type: Opaque
stringData:
  name: client-$i
  server: $HOST
  clusterResources: "true"
  project: client-$i
  config: |
    {
      "bearerToken":"$TOKEN",
      "tlsClientConfig": {
        "caData": "$CA"
      }
    }
EOF

kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: client-$i
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  destinations:
  - name: client-$i
    namespace: '*'
    server: $HOST
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  roles:
  - name: admin
    policies:
    - p, proj:client-$i:admin, applications, *, client-$i/*, allow
  sourceRepos:
  - '*'
status:
  jwtTokensByRole:
    admin: {}
EOF

kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-client-$i
  namespace: argocd
spec:
  project: client-$i
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    name: client-$i
    namespace: guestbook
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
EOF

done
