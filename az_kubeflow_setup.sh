#!/bin/sh

# *****************************************************************************
# Copyright (c) 2021 VolksInfotech.com
# MIT License
# 
# DISCLAIMER: 
# THIS PROGRAM IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE PROGRAM OR THE USE OR OTHER DEALINGS IN THE
# PROGRAM.
# ********************************************************************************

#
# Script to install Kubeflow v1.2 in Azure Kubernetes Service from a GUI based 
# RHEL7/Centos7/Ubuntu18 machine (Jump server). Jump server should have wget, tar 
# Kubectl to manage kubernetes and az cli to manage MS Azure infra. The easiest way 
# to execute below commands will be using Azure Cloud shell. Make sure to update
# variable section.   
#

#
# Variables Used, update below as required
#
SUBSCRIPTION=aaaa-bbbb-cccc-dddd            # Azure subscription
RESOURCE_GROUP_NAME=kubeflow-rg             # Azure Resourcegroup
LOCATION=eastus                             # Azure location
KUNERNETES_NAME=KubeflowCluster             # Azure kubernetes cluster Name
AGENT_SIZE=Standard_D4s_v3                  # For GPU based ML training use appropriate type for example AGENT_SIZE=Standard_NC6
AGENT_COUNT=2                               # Azure kubernetes agent count
KUBEFLOW_URL=https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz    # Kubeflow URL
KUBEFLOW_NAME=mykubeflow                    # Kubeflow Deployment Name
BASE_DIR=`pwd`                              # Base directory for deployments
CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml" # Kubeflow configuration URI

######################################################################################################################

check_execution() {
if [ $? -eq 0 ]; then
  echo "==========================================================="
  echo "> Successfull: $1"
  echo "==========================================================="
else
  echo "==========================================================="
  echo "> Failed: $1"
  echo "==========================================================="
  exit
fi
}

# Login to azure
az login

# Set subscription
az account set --subscription $SUBSCRIPTION

# Create a resource group
az group create -n $RESOURCE_GROUP_NAME -l $LOCATION
check_execution "To create Azure Resource Group"

# Create a resource group
az aks create -g $RESOURCE_GROUP_NAME -n $KUNERNETES_NAME -s $AGENT_SIZE -c $AGENT_COUNT -l $LOCATION --generate-ssh-keys
check_execution "To create Azure Kubernetes Cluster"

# Sleep time to settle all k8 components
sleep 120

# Create user credentials
az aks get-credentials -n $KUNERNETES_NAME -g $RESOURCE_GROUP_NAME

# Download Kubeflow
wget -O kfctl.tar.gz $KUBEFLOW_URL 
check_execution "To download Kubeflow"

# Untar downloaded file
tar -xvf kfctl.tar.gz
check_execution "To extract Kubeflow tarball"

# Set currrent location in PATH
CURRENT_LOCATION=`pwd`
export PATH=$PATH:$CURRENT_LOCATION

# Base directory where you want to store one or more Kubeflow deployments
export KF_NAME=$KUBEFLOW_NAME
export BASE_DIR=$BASE_DIR
export KF_DIR=${BASE_DIR}/${KF_NAME}

# Setting up location and configuration file to use when deploying Kubeflow
mkdir -p ${KF_DIR}
cd ${KF_DIR}
export CONFIG_URI=$CONFIG_URI
kfctl apply -V -f ${CONFIG_URI}
check_execution "To configure kubeflow"

# Sleep time to settle all kubeflow components
sleep 120

# To get resources deployed for kubeflow
kubectl get all -n kubeflow
check_execution "To get kubeflow resources"

# Port-forwarding to access cluster
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80

# Open in browser http://localhost:8080  to access Kubeflow dashboard
