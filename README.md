# Kubeflow
Kubeflow is an open-source platform running on top of Kubernetes and designed to make machine learning (ML) workflow simple, portable and scalable.

# About Script
Script will install Kubeflow v1.2 in Azure Kubernetes Service. Script can be executed from an GUI (Desktop) based RHEL7.x/Centos7.x/Ubuntu16 machine (Jump server). 

Jump server should have few utilities like wget to download kubeflow, tar to extract tar ball, Kubectl to manage kubernetes and AZ cli to manage MS Azure infra. 
The easiest way to execute script will be using Azure Cloud shell. 

# Notes
- Make sure to update variable section.  
- Desktop based machine helps in accessing Kubeflow Dashboard. 
