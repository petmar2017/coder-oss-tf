# Coder OSS with Terraform

The purpose of this repo is to demonstrate how remote development environments work using [Coder's OSS product](https://github.com/coder/coder). This repo should not be used for production use cases, but simply a proof-of-concept for what coding-in-a-browser feels like using Coder.

## setup

run ./setup/dev_container_setup.sh from the root

## original artical:

https://medium.com/@elliotgraebert/laptop-development-is-dead-why-remote-development-is-the-future-f92ce103fd13


## once the install is finished you can launch the code app by clicking on the below IP

![Alt text](./docs/image-coder-k8s-cluster-ip.png)

## how to run custom scripts on the AKS cluster without CLI access
![zure kubcert image](./docs/image-aks-cli-commands.png)



## original docu


<img src="docs/vscode.png" width="300">

## Currently supported platforms

Each subfolder in this repo is for a different platform.

* Google GKE 
* Azure AKS
* AWS EKS
* Linode LKE
* DigitalOcean DOKS
* IBMCloud K8s
* OVHCloud K8s
* Scaleway K8s Kapsule


## Important Caveat

In order to make this demo "1 click apply", I am using an anti-pattern where I create the k8s cluster and deploy in the same repo. This is a [known](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources) anti-pattern. The consequence is that you can get authentication errors while trying to update the namespace or helm charts. For the most part, things have "just worked" for me. You can fix this by file mounting a kubeconfig (ovhcloud-k8s shows how to do this).


