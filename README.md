# vagrant-ha-kubernetes 

##### The contents of this repo are a work in progress

vagrant-ha-kubernetes is a Vagrantfile and collection of configuration files and ansible playbooks that aims to automatically set up and configure a 6 node HA kubernetes cluster using kubeadm. The cluster should consist of 3 master nodes each running a systemd managed instance of etcd and 3 worker nodes. This is quick and dirty and could do with a lot of refinement, which I may or may not get around to.

### Requirements

You'll need the vagrant hostmanager plugin will automatically configure guest /etc/hosts files for DNS resolution.

This is tested using the following software versions:

* Windows 10
* Virtualbox 5.2.8 r121009
* Vagrant 2.0.2
* vagrant-hostmanage 1.8.7

### Limitations

We're using ansible_local as the vagrant provisioner. Each guest is provisioned in sequence as they are specified in servers.yaml and each playbook is run in order. Each guests playbooks are executed through to completion before moving onto the next server.

As such, things start to get a bit complicated towards the end where I want to run some operations in parallel. Essentially this just does all of the pre-reqs of setting up a HA k8s cluster. The last bit is currently a manual step which seems to be a bit hit and miss.

Because this was thrown together quickly there's quite a bit of stuff that's hard coded. As such, don't try to change the IPs used or the guest hostnames unless you're prepared to go through all the files and change every reference.

### To-Do List

* Add an ingress controller
* Tidy up everything
* Remove lots of hard-coded bits and make the deployment a bit more flexible
* Refine the ansible playbooks, maybe switch from ansible_local to ansible_server...maybe

### Usage

* git clone the repo
* vagrant up 
* Wait about 15-20 minutes

Once vagrant up is finished, then comes the manual steps. It's worth taking a snapshot at this point...

`vagrant snapshot push`

##### ON K8S-MASTER1

```
sudo -s
kubeadm init --config=/vagrant/config.yaml

mkdir -p /home/vagrant/.kube
cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
```

##### ON K8S-MASTER2/3

```
sudo -s
mkdir -p /etc/kubernetes/pki/etcd
scp -o StrictHostKeyChecking=no root@k8s-master1:/etc/kubernetes/pki/etcd/ca.pem /etc/kubernetes/pki/etcd
scp -o StrictHostKeyChecking=no root@k8s-master1:/etc/kubernetes/pki/etcd/client.pem /etc/kubernetes/pki/etcd
scp -o StrictHostKeyChecking=no root@k8s-master1:/etc/kubernetes/pki/etcd/client-key.pem /etc/kubernetes/pki/etcd
scp -o StrictHostKeyChecking=no root@k8s-master1:/etc/kubernetes/pki/* /etc/kubernetes/pki
kubeadm init --config=/vagrant/config.yaml
```

##### ON K8S-MASTER1

```
wget https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/rbac.yaml
wget https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml
```

Edit canal.yaml change canal_iface to eth1

```
su - vagrant
kubectl apply -f rbac.yaml
kubectl apply -f canal.yaml
```

##### ON WORKERS

kubeadm join --token mydemo.0123456789abcdef 192.168.34.100:6443 --discovery-token-unsafe-skip-ca-verification
