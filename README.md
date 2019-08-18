# balena-tttest


UI
Terraform 
	Create s3 bucket
	Create cloudfront point to bucket 
	DNS record to point to domain
bashscript
TODO: Create bash script to do releases which ties into CI (make life easier) 

API

VPC
Creates a public and private vpc
Spreads it across 2 az minimum
Setup acl to allow DNS HTTP/ HTTPS out publicly

EKS
Create EKS cluster 
Setup logging to go to cloudwatch 
Setup prometheus collectors to forward data to it 
	APP
Create HELMl file
Use AWS loadblanacer
Setup container env variables
Setup prometheus injestor
Document steps to deploy app 
TODO: Bashscript to deploy latest version



DB
Terraform
Take input from VPC to deploy RDS 
Create SG and allow subnet from EKS to access it 
Setup a snapshot timeframe
Setup prometheus data collectors

Prometheus
HELM
Run prometheus server
Setup replication or data migration
Setup multi az for instance

