sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo hostnamectl set-hostname "master-node"
exec bash
 
sudo hostnamectl set-hostname "worker-node1"
exec bash
 
sudo nano /etc/hosts
 
192.168.0.109 master-node  
192.168.0.151 worker-node1
 
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
 
sudo modprobe overlay
sudo modprobe br_netfilter
 
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
 
# Apply sysctl params without reboot
sudo sysctl --system
 
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y kubelet=1.26.5-00 kubeadm=1.26.5-00 kubectl=1.26.5-00
 
sudo apt install docker.io
sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd.service
sudo systemctl restart kubelet.service
sudo systemctl enable kubelet.service
 
7
 
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=192.168.0.0/24
 
 
 
 
 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 
Your Kubernetes control-plane has initialized successfully!
 
To start using your cluster, you need to run the following as a regular user:
 
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
 
Alternatively, if you are the root user, you can run:
 
  export KUBECONFIG=/etc/kubernetes/admin.conf
 
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
https://kubernetes.io/docs/concepts/cluster-administration/addons/
 
Then you can join any number of worker nodes by running the following on each as root:
 
kubeadm join 192.168.0.100:6443 --token 4q8lmv.hhy6nxsplbzsrtrz \
	--discovery-token-ca-cert-hash sha256:67061180b94c3db187a0892dff30e42e5124f19832a8630ff478e32e280ac406 
root@master-node:/home/ubuntu#
 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 
 
 
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml
