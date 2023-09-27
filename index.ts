import * as scw from "@lbrlabs/pulumi-scaleway"

export const clusterKubeconfig: { [key: string]: any } = {}
const clustesName = ["admin", "c1", "c2", "c3"]
const clusters = clustesName.map((name) => {
  const c = new scw.KubernetesCluster(`${name}-cluster`, {
    name: `argocd-${name}`,
    cni: "cilium",
    region: "fr-par",
    version: "1.27.4",
    deleteAdditionalResources: true,
  })

  new scw.KubernetesNodePool(`${name}-node`, {
    name: `argocd-${name}`,
    clusterId: c.id,
    size: 1,
    nodeType: "DEV1-M",
  }, { parent: c })

  clusterKubeconfig[name] = c.kubeconfigs

  return c
})


