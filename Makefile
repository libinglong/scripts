cfssl=build/bin/cfssl
cfssljson=build/bin/cfssljson
kubectl=build/bin/kubectl
master_address=192.160.3.30

clean:
	rm -rf build

build/etcd/etcd-root-ca.pem build/etcd/etcd-root-ca-key.pem: $(cfssl) $(cfssljson)
	mkdir -p build/etcd
	$(cfssl) gencert --initca=true k8s-certs/etcd/ca.csr.json | $(cfssljson) --bare build/etcd/etcd-root-ca

build/etcd/s1.pem build/etcd/s1-key.pem build/etcd/s2.pem build/etcd/s2-key.pem build/etcd/s3.pem build/etcd/s3-key.pem: $(cfssl) $(cfssljson) build/etcd/etcd-root-ca.pem build/etcd/etcd-root-ca-key.pem
	$(cfssl) gencert \
		--ca build/etcd/etcd-root-ca.pem \
		--ca-key build/etcd/etcd-root-ca-key.pem \
		--config k8s-certs/etcd/etcd-gencert.json \
		k8s-certs/etcd/s1-ca-csr.json | $(cfssljson) --bare build/etcd/s1
	$(cfssl) gencert \
		--ca build/etcd/etcd-root-ca.pem \
		--ca-key build/etcd/etcd-root-ca-key.pem \
		--config k8s-certs/etcd/etcd-gencert.json \
		k8s-certs/etcd/s2-ca-csr.json | $(cfssljson) --bare build/etcd/s2
	$(cfssl) gencert \
		--ca build/etcd/etcd-root-ca.pem \
		--ca-key build/etcd/etcd-root-ca-key.pem \
		--config k8s-certs/etcd/etcd-gencert.json \
		k8s-certs/etcd/s3-ca-csr.json | $(cfssljson) --bare build/etcd/s3



build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem: $(cfssl) $(cfssljson)
	mkdir -p build/k8s-ca
	$(cfssl) gencert -initca k8s-certs/k8s-ca/ca.csr.json | $(cfssljson) -bare build/k8s-ca/myk8s-root

build/k8s-ca/front-proxy-ca.pem build/k8s-ca/front-proxy-ca-key.pem: $(cfssl) $(cfssljson)
	mkdir -p build/k8s-ca
	$(cfssl) gencert -initca k8s-certs/k8s-ca/front-proxy-ca.csr.json | $(cfssljson) -bare build/k8s-ca/front-proxy-ca



build/apiserver/apiserver-tls.pem build/apiserver/apiserver-tls-key.pem: build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	mkdir -p build/apiserver
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/apiserver/apiserver-tls.csr.json | $(cfssljson) -bare build/apiserver/apiserver-tls

build/apiserver/front-proxy-client.pem build/apiserver/front-proxy-client-key.pem: build/k8s-ca/front-proxy-ca.pem build/k8s-ca/front-proxy-ca-key.pem
	$(cfssl) gencert \
		-ca=build/k8s-ca/front-proxy-ca.pem \
		-ca-key=build/k8s-ca/front-proxy-ca-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/apiserver/front-proxy-client.csr.json | $(cfssljson) -bare build/apiserver/front-proxy-client

build/apiserver/kube-apiserver-kubelet-client.pem build/apiserver/kube-apiserver-kubelet-client-key.pem: build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/apiserver/kube-apiserver-kubelet-client.csr.json | $(cfssljson) -bare build/apiserver/kube-apiserver-kubelet-client

build/client-to-apiserver/kube-client-admin.pem build/client-to-apiserver/kube-client-admin-key.pem : $(cfssl) $(cfssljson) build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	mkdir -p build/client-to-apiserver
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/client-to-apiserver/kubeconfig-admin.csr.json | $(cfssljson) -bare build/client-to-apiserver/kube-client-admin


build/client-to-apiserver/kube-proxy.pem build/client-to-apiserver/kube-proxy-key.pem : $(cfssl) $(cfssljson) build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/client-to-apiserver/kube-proxy.csr.json | $(cfssljson) -bare build/client-to-apiserver/kube-proxy


build/client-to-apiserver/192.160.3.28-kubelet.pem build/client-to-apiserver/192.160.3.28-kubelet-key.pem : $(cfssl) $(cfssljson) build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/client-to-apiserver/192.160.3.28-kubelet.csr.json | $(cfssljson) -bare build/client-to-apiserver/192.160.3.28-kubelet

build/client-to-apiserver/192.160.3.29-kubelet.pem build/client-to-apiserver/192.160.3.29-kubelet-key.pem : $(cfssl) $(cfssljson) build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/client-to-apiserver/192.160.3.29-kubelet.csr.json | $(cfssljson) -bare build/client-to-apiserver/192.160.3.29-kubelet



build/client-to-apiserver/kube-controller-manager.pem build/client-to-apiserver/kube-controller-manager-key.pem : $(cfssl) $(cfssljson) build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/client-to-apiserver/kube-controller-manager.csr.json | $(cfssljson) -bare build/client-to-apiserver/kube-controller-manager


build/client-to-apiserver/kube-scheduler.pem build/client-to-apiserver/kube-scheduler-key.pem : $(cfssl) $(cfssljson) build/k8s-ca/myk8s-root.pem build/k8s-ca/myk8s-root-key.pem
	$(cfssl) gencert \
		-ca=build/k8s-ca/myk8s-root.pem \
		-ca-key=build/k8s-ca/myk8s-root-key.pem \
		-config=k8s-certs/k8s-ca/ca.config.json \
		-profile=kubernetes \
		k8s-certs/client-to-apiserver/kube-scheduler.csr.json | $(cfssljson) -bare build/client-to-apiserver/kube-scheduler


build/kubeconfig/admin.conf: build/client-to-apiserver/kube-client-admin.pem build/client-to-apiserver/kube-client-admin-key.pem build/k8s-ca/myk8s-root.pem $(kubectl)
	$(kubectl) config set-cluster kubernetes --certificate-authority=build/k8s-ca/myk8s-root.pem --embed-certs=true --server=https://${master_address}:8443 --kubeconfig build/kubeconfig/admin.conf
	$(kubectl) config set-credentials admin --client-certificate=build/client-to-apiserver/kube-client-admin.pem --embed-certs=true --client-key=build/client-to-apiserver/kube-client-admin-key.pem --kubeconfig build/kubeconfig/admin.conf
	$(kubectl) config set-context kubernetes --cluster=kubernetes --user=admin --kubeconfig build/kubeconfig/admin.conf
	$(kubectl) config use-context kubernetes --kubeconfig build/kubeconfig/admin.conf

build/kubeconfig/kube-proxy.conf: build/client-to-apiserver/kube-proxy.pem build/client-to-apiserver/kube-proxy-key.pem build/k8s-ca/myk8s-root.pem $(kubectl)
	$(kubectl) config set-cluster kubernetes --certificate-authority=build/k8s-ca/myk8s-root.pem --embed-certs=true --server=https://${master_address}:8443 --kubeconfig build/kubeconfig/kube-proxy.conf
	$(kubectl) config set-credentials kube-proxy --client-certificate=build/client-to-apiserver/kube-proxy.pem --embed-certs=true --client-key=build/client-to-apiserver/kube-proxy-key.pem --kubeconfig build/kubeconfig/kube-proxy.conf
	$(kubectl) config set-context kubernetes --cluster=kubernetes --user=kube-proxy --kubeconfig build/kubeconfig/kube-proxy.conf
	$(kubectl) config use-context kubernetes --kubeconfig build/kubeconfig/kube-proxy.conf

build/kubeconfig/kube-controller-manager.conf: build/client-to-apiserver/kube-controller-manager.pem build/client-to-apiserver/kube-controller-manager-key.pem build/k8s-ca/myk8s-root.pem $(kubectl)
	$(kubectl) config set-cluster kubernetes --certificate-authority=build/k8s-ca/myk8s-root.pem --embed-certs=true --server=https://${master_address}:8443 --kubeconfig build/kubeconfig/kube-controller-manager.conf
	$(kubectl) config set-credentials kube-controller-manager --client-certificate=build/client-to-apiserver/kube-controller-manager.pem --embed-certs=true --client-key=build/client-to-apiserver/kube-controller-manager-key.pem --kubeconfig build/kubeconfig/kube-controller-manager.conf
	$(kubectl) config set-context kubernetes --cluster=kubernetes --user=kube-controller-manager --kubeconfig build/kubeconfig/kube-controller-manager.conf
	$(kubectl) config use-context kubernetes --kubeconfig build/kubeconfig/kube-controller-manager.conf



build/kubeconfig/kube-scheduler.conf: build/client-to-apiserver/kube-scheduler.pem build/client-to-apiserver/kube-scheduler-key.pem build/k8s-ca/myk8s-root.pem $(kubectl)
	$(kubectl) config set-cluster kubernetes --certificate-authority=build/k8s-ca/myk8s-root.pem --embed-certs=true --server=https://${master_address}:8443 --kubeconfig build/kubeconfig/kube-scheduler.conf
	$(kubectl) config set-credentials kube-scheduler --client-certificate=build/client-to-apiserver/kube-scheduler.pem --embed-certs=true --client-key=build/client-to-apiserver/kube-scheduler-key.pem --kubeconfig build/kubeconfig/kube-scheduler.conf
	$(kubectl) config set-context kubernetes --cluster=kubernetes --user=kube-scheduler --kubeconfig build/kubeconfig/kube-scheduler.conf
	$(kubectl) config use-context kubernetes --kubeconfig build/kubeconfig/kube-scheduler.conf

# 改为使用bootstrap tls
#kubelet_28_conf=build/kubeconfig/192.160.3.28-kubelet.conf
#build/kubeconfig/192.160.3.28-kubelet.conf: build/client-to-apiserver/192.160.3.28-kubelet.pem build/client-to-apiserver/192.160.3.28-kubelet-key.pem build/k8s-ca/myk8s-root.pem $(kubectl)
#	$(kubectl) config set-cluster kubernetes --certificate-authority=build/k8s-ca/myk8s-root.pem --embed-certs=true --server=https://${master_address}:8443 --kubeconfig ${kubelet_28_conf}
#	$(kubectl) config set-credentials kubelet --client-certificate=build/client-to-apiserver/192.160.3.28-kubelet.pem --embed-certs=true --client-key=build/client-to-apiserver/192.160.3.28-kubelet-key.pem --kubeconfig ${kubelet_28_conf}
#	$(kubectl) config set-context kubernetes --cluster=kubernetes --user=kubelet --kubeconfig ${kubelet_28_conf}
#	$(kubectl) config use-context kubernetes --kubeconfig ${kubelet_28_conf}

# 改为使用bootstrap tls
#kubelet_29_conf=build/kubeconfig/192.160.3.29-kubelet.conf
#build/kubeconfig/192.160.3.29-kubelet.conf: build/client-to-apiserver/192.160.3.29-kubelet.pem build/client-to-apiserver/192.160.3.29-kubelet-key.pem build/k8s-ca/myk8s-root.pem $(kubectl)
#	$(kubectl) config set-cluster kubernetes --certificate-authority=build/k8s-ca/myk8s-root.pem --embed-certs=true --server=https://${master_address}:8443 --kubeconfig ${kubelet_29_conf}
#	$(kubectl) config set-credentials kubelet --client-certificate=build/client-to-apiserver/192.160.3.29-kubelet.pem --embed-certs=true --client-key=build/client-to-apiserver/192.160.3.29-kubelet-key.pem --kubeconfig ${kubelet_29_conf}
#	$(kubectl) config set-context kubernetes --cluster=kubernetes --user=kubelet --kubeconfig ${kubelet_29_conf}
#	$(kubectl) config use-context kubernetes --kubeconfig ${kubelet_29_conf}

apiserver-certs: build/apiserver/apiserver-tls.pem build/apiserver/apiserver-tls-key.pem \
	build/apiserver/front-proxy-client.pem build/apiserver/front-proxy-client-key.pem \
	build/apiserver/kube-apiserver-kubelet-client.pem build/apiserver/kube-apiserver-kubelet-client-key.pem \
	build/apiserver/sa.pub build/apiserver/sa.key

client-to-apiserver-certs: build/client-to-apiserver/kube-client-admin.pem build/client-to-apiserver/kube-client-admin-key.pem \
	build/client-to-apiserver/kube-proxy.pem build/client-to-apiserver/kube-proxy-key.pem \
	build/client-to-apiserver/kube-controller-manager.pem build/client-to-apiserver/kube-controller-manager-key.pem


etcd-certs: build/etcd/s1.pem build/etcd/s1-key.pem \
	build/etcd/s2.pem build/etcd/s2-key.pem \
	build/etcd/s3.pem build/etcd/s3-key.pem

build/apiserver/sa.key build/apiserver/sa.pub: /usr/bin/openssl
	openssl genrsa -out build/apiserver/sa.key 2048
	openssl rsa -in build/apiserver/sa.key -pubout -out build/apiserver/sa.pub


kubeconfigs: build/kubeconfig/admin.conf build/kubeconfig/kube-proxy.conf build/kubeconfig/kube-controller-manager.conf \
	build/kubeconfig/kube-scheduler.conf

build/bin/cfssl build/bin/cfssljson build/bin/kubectl:
	mkdir -p build/bin
	curl -sSL https://github.com/cloudflare/cfssl/releases/download/v1.6.2/cfssl_1.6.2_linux_amd64 -o build/bin/cfssl
	chmod +x build/bin/cfssl
	curl -sSL https://github.com/cloudflare/cfssl/releases/download/v1.6.2/cfssljson_1.6.2_linux_amd64 -o build/bin/cfssljson
	chmod +x build/bin/cfssljson
	curl -sSL "https://dl.k8s.io/release/v1.22.14/bin/linux/amd64/kubectl" -o build/bin/kubectl
	chmod +x build/bin/kubectl

.PHONY: all apiserver-certs client-to-apiserver-certs kubeconfigs

all: etcd-certs apiserver-certs client-to-apiserver-certs kubeconfigs


bootstrap_kubelet_conf=build/kubeconfig/bootstrap-kubelet.conf
build/kubeconfig/bootstrap-kubelet.conf : build/bin/kubectl
	$(kubectl) config set-cluster kubernetes --certificate-authority=build/k8s-ca/myk8s-root.pem --embed-certs=true --server=https://${master_address}:8443 --kubeconfig ${bootstrap_kubelet_conf}
	$(kubectl) config set-credentials kubelet --token=${token} --kubeconfig ${bootstrap_kubelet_conf}
	$(kubectl) config set-context kubernetes --cluster=kubernetes --user=kubelet --kubeconfig ${bootstrap_kubelet_conf}
	$(kubectl) config use-context kubernetes --kubeconfig ${bootstrap_kubelet_conf}

run-kubelet: build/kubeconfig/bootstrap-kubelet.conf
	@[ -n "${token}" ] || { echo "Please add token=... on the command line"; exit 1; }
	@[ -n "${node_ip}" ] || { echo "Please add node_ip=... on the command line"; exit 1; }
	sed -i 's/healthzBindAddress: ##node_ip/healthzBindAddress: ${node_ip}/g' k8s-node/config.yaml
	chmod +x command/node/kubelet.sh && command/node/kubelet.sh ${node_ip}