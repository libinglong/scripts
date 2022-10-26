
== csr说明
kubeconfig.csr.json O: "system:masters", 这对应clusterrolebinding cluster-admin 因此是超管权限
kube-proxy.csr.json CN: "system:kube-proxy", 这对应clusterrolebinding system:node-proxier

kubelet.csr.json CN:"system:node:<nodeName>" O: "system:nodes" 
> nodeName的值必须与kubelet注册到apiserver的名称精确匹配，默认情况下，这是 hostname 提供的主机名，
或者通过 kubelet 选项 --hostname-override 覆盖。但是，在使用 --cloud-provider kubelet 选项时，
具体的主机名可能由云提供商确定，忽略本地主机名和 --hostname-override 选项。 

> 这实际上使用的不是RBAC了，其对应authorization-mode=Node，使用的是Node鉴权

> k8s 1.8(含)版本后，不再推荐使用clusterbinding处理node鉴权，参考
https://blog.frognew.com/2021/05/k8s-apiserver-authorization-mode-node.html
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#core-component-roles
https://kubernetes.io/docs/reference/access-authn-authz/node/


kube-controller-manager.csr.json CN = system:kube-controller-manager 这对应clusterrolebinding system:kube-controller-manager
kube-scheduler.csr.json CN: system:kube-scheduler 这对应clusterrolebinding system:kube-scheduler

docker切换containerd运行时，如果是先装的docker，删除/etc/containerd/config.toml中的disabled_plugins = ["cri"]

