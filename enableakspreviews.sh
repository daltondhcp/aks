#Install aks-preview extension
az extension add --name aks-preview

#Add preview features to subscription
az feature register -n WindowsPreview --namespace Microsoft.ContainerService
az feature register -n AKSLockingDownEgressPreview --namespace Microsoft.ContainerServie
az feature register -n MultiAgentpoolPreview --namespace Microsoft.ContainerService
az feature register -n APIServerSecurityPreview --namespace Microsoft.ContainerService
az feature register -n VMSSPreview --namespace Microsoft.ContainerService
az feature register -n AKSAuditLog --namespace Microsoft.ContainerService
az feature register -n PodSecurityPolicyPreview --namespace Microsoft.ContainerService
az feature register -n AKSAzureStandardLoadBalancer --namespace "Microsoft.ContainerService" 

az provider register -n Microsoft.ContainerService
