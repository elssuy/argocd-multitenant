.ONESHELL:

export-admin:
	pulumi stack output  --show-secrets -j | jq ".clusterKubeconfig.admin[0].configFile" -r > .kubeconfig-admin

export-clients:
	pulumi stack output  --show-secrets -j | jq ".clusterKubeconfig.c1[0].configFile" -r > .kubeconfig-c1
	pulumi stack output  --show-secrets -j | jq ".clusterKubeconfig.c2[0].configFile" -r > .kubeconfig-c2
	pulumi stack output  --show-secrets -j | jq ".clusterKubeconfig.c3[0].configFile" -r > .kubeconfig-c3

