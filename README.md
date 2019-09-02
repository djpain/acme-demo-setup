# ACME-DEMO

So I broke this down into specific tasks.

#### UI
	Create s3 bucket
	Create cloudfront point to bucket 
	TODO: Create bash script to do releases which ties into CI (make life easier)
	TODO: Setup dns to point to acme.com ( I dont have a domain)

#### VPC
	Creates a public and private vpc
	Spreads it across 2 AZ as a minimum
	TODO: Setup acl to allow DNS HTTP/ HTTPS out publicly

#### EKS
	Create EKS cluster 
	TODO: Setup logging to go to cloudwatch 
	TODO: Setup prometheus collectors to forward data to it 

#### APP
	Create HELM file for API
	Use AWS loadblanacer
	Setup container env variables
	Setup prometheus 
	Document steps to deploy app 
	Helm chart to install ALB 
	TODO: Bashscript to deploy latest version

#### DB
	Take input from VPC to deploy RDS 
	Create SG and allow subnet from EKS to access it 
	Setup a snapshot timeframe
	TODO: Setup prometheus data collectors

#### Prometheus
	Initalise from helm chart

To make it easier I made a graph showing all infrastructure layout
![alt text](Images/AWS.png "AWS Dev enviroment")


## Pre-Requiset  
To get this all deployed you will need `TFENV`, `Terraform v0.12`, `kubectl`, `awscli` and the `aws-iam-authenticator`. To install the `aws-iam-authenticator` you will need to have go installed localy and your $PATH pointing to you `go/bin` directory.

setting up go path
`export PATH="$HOME/go/bin:$PATH"`
installing aws iam authenticator
`go get -u -v sigs.k8s.io/aws-iam-authenticator/cmd/aws-iam-authenticator`

### TFENV

`git clone https://github.com/tfutils/tfenv.git ~/.tfenv`
`export PATH="$HOME/.tfenv/bin:$PATH"`
`tfenv install 0.12.7` 

## Creating the infrastructure 

Once you have all the tools installed you will need to go to the root directory of this repo. From there run the command `terraofrm workspace new {enviroment name}` and then `terraform init`. Terraform will go then and get all the required modules to setup the required infrastructure.

Once you are ready you can run the following command 

`terraform plan -var-file=ENV/s3-dev.tfvars -var-file=ENV/dev.tfvars -var-file=ENV/rds-dev.tfvars -out dev.out`

What this does is run a plan of what terraform will build. It uses the variable files from the `ENV` directory. Once completed you will need to run the following command to start the building of the infrastructure.

`terraform apply "dev.out"`

This will setup a S3 bucket where the static website will be served from.From here it wil then start building the VPC with public subnets and private subnets across all three australian az. 
Once the VPC creation is completed it will start the creation of the postgres Master server and then the ASG for the EKS cluster. When the Postgres Master is completed it will then start building the Postgres Slave. Both of these services will be running  in the private subnet. Grab a coffe as this usually takes about 15 minutes to create from scratch.

Once the EKS cluster is setup it will generate the kubcetl config file which you can use to connect to the cluster.

## Connecting to EKS

To connect to the cluster run the following command 

`kubectl get namespaces --kubeconfig=kubeconfig_test-eks-YySjiu2M`

This will show you all the name spaces available.

NAME          STATUS   AGE
default       Active   134m
kube-public   Active   134m
kube-system   Active   134m

Or 

`kubectl get svc --kubeconfig=kubeconfig_test-eks-YySjiu2M`

NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   3h38m


## Destorying the infrastructure 

Once you want to destroy all the infrastructure you will just need to run the following command

`terraform destroy -var-file=ENV/s3-dev.tfvars -var-file=ENV/dev.tfvars -var-file=ENV/rds-dev.tfvars`

# HELM and deploying apps 

To deploy the applications we will be using helm to deploy applications to kubernettes. https://helm.sh/

## Helm init 

To initalise helm you will need to run the following command

`helm init`

Now we need to setup k8s to work with it and tiller. To do this please follow this guide from AWS.
https://docs.aws.amazon.com/eks/latest/userguide/helm.html

## Deploying applications to kubernettes

### Installing prometheus using helm

Once you have initalised helm you just need to run the following command to setup prometheus

`helm install stable/prometheus --name test-prometheus -f HELM/prometheus_values.yaml --kubeconfig={ClusterConfigFile}`

### Setting ALB intergration

#### kube2iam

#### Installing ingergrator 
This setups for a service to be able to manage the AWS ALB and redirect traffic from a load balancer through to the container. 

`helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator --kubeconfig=`

`helm install incubator/aws-alb-ingress-controller --set autoDiscoverAwsRegion=true --set autoDiscoverAwsVpcID=true --set clusterName=test-cluster --kubeconfig=`

### Deploying the API application

`
