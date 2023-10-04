# FluxCD & ArgoCD sandbox

This projet is used as sandbox for testing ArgoCD and FluxCD.
Pulumi is used as a IAC tool to deploy 4 clusters with each one node in Scaleway.

Requirements:
- Pulumi: [Get here](https://www.pulumi.com/docs/install/)
- Flux: [Get here](https://fluxcd.io/flux/installation/)
- Kubectl: [Get here](https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/)
- Scaleway account [Website](https://www.scaleway.com/en/)

1. Export your scaleway tokens

```sh
export SCW_ACCESS_KEY=
export SCW_SECRET_KEY=
export SCW_DEFAULT_PROJECT_ID=
```

2. Export Pulumi variables

To simplify pulumi usage we are using a local state folder:

```sh
export PULUMI_BACKEND_URL=file://absolute/path/to/state/folder/.pulumi
export PULUMI_CONFIG_PASSPHRASE=""
```

3. Run pulumi to deploy kubernetes clusters

```sh
pulumi up
```

4. Export kubeconfig files to access clusters

```sh
make export-admin
make export-clients
```

# For FluxCD experimentation

1. Export kubeconfig for client cluster

```sh
export KUBECONFIG=.kubeconfig-c1
```

2. Deploy FluxCD

```sh
kubectl apply -k kustomization/client-2/flux/flux-system/ 
```

# For ArgoCD

1. Export admin cluster

```sh
export KUBECONFIG=.kubeconfig-admin
```

2. Run installation scripts

```sh
./hack/install-nginx.sh
# [...]

./hack/install-argocd.sh
# [...]
Use this url to connect to argocd admin interface (ssl use self-signed certificate)
https://argocd.xxx.xxx.xxx.xxx.nip.io
Use this command line to get admin password: (it takes time please wait a little bit)
kubectl get secret/argocd-initial-admin-secret -n argocd -o go-template='{{.data.password}}' | base64 -d
```

3. Connect to admin interface

Username is: `admin`
Password can be found using this command line:
```sh
kubectl get secret/argocd-initial-admin-secret -n argocd -o go-template='{{.data.password}}' | base64 -d
```



