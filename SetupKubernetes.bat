# Pre-requisites
# Install Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
# Login Azure

az login

mkdir C:\SSH
ssh-keygen -m PEM -t rsa -b 4096 -f C:\SSH\aks

az aks create -g NetworkWatcherRG -n luxekube --subscription Yearly --network-plugin azure --enable-addons azure-keyvault-secrets-provider --aks-custom-headers EnableAzureDiskFileCSIDriver=true --node-vm-size=Standard_D2s_v3 --location=eastus2 --ssh-key-value C:\SSH\aks.pub

az aks nodepool scale --name nodepool1 --cluster-name luxekube --resource-group NetworkWatcherRG --subscription Yearly --node-count 1


docker login luxurai.azurecr.io --username luxurai --password $(luxeContainers)

docker pull apache/kafka
docker pull k8s.gcr.io/kubernetes-zookeeper:1.0-3.4.10

docker tag apache/kafka:latest luxurai.azurecr.io/kafka:1
docker push luxurai.azurecr.io/kafka:1

docker tag k8s.gcr.io/kubernetes-zookeeper:1.0-3.4.10 luxurai.azurecr.io/zookeeper:1
docker push luxurai.azurecr.io/zookeeper:1

#### Enable Azure managed identity authentication for Kubernetes clusters with kubelogin
#### https://learn.microsoft.com/en-us/azure/aks/enable-authentication-microsoft-entra-id

az aks update --name luxekube --resource-group NetworkWatcherRG --subscription Yearly --enable-oidc-issuer --enable-workload-identity

{
  "aadProfile": null,
  "addonProfiles": {
    "azureKeyvaultSecretsProvider": {
      "config": {
        "enableSecretRotation": "false",
        "rotationPollInterval": "2m"
      },
      "enabled": true,
      "identity": {
        "clientId": "7f79cd96-23e9-4d8d-acc4-f060e53e7252",
        "objectId": "5d52e015-ae13-44e5-b076-67c09ae2211b",
        "resourceId": "/subscriptions/4ebf4283-e95c-4bff-8fe2-5b536d1c8d70/resourcegroups/MC_NetworkWatcherRG_luxekube_eastus2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurekeyvaultsecretsprovider-luxekube"
      }
    }
  },
  "agentPoolProfiles": [
    {
      "availabilityZones": null,
      "capacityReservationGroupId": null,
      "count": 1,
      "creationData": null,
      "currentOrchestratorVersion": "1.28.9",
      "enableAutoScaling": false,
      "enableEncryptionAtHost": false,
      "enableFips": false,
      "enableNodePublicIp": false,
      "enableUltraSsd": false,
      "gpuInstanceProfile": null,
      "hostGroupId": null,
      "kubeletConfig": null,
      "kubeletDiskType": "OS",
      "linuxOsConfig": null,
      "maxCount": null,
      "maxPods": 30,
      "minCount": null,
      "mode": "System",
      "name": "nodepool1",
      "networkProfile": null,
      "nodeImageVersion": "AKSUbuntu-2204gen2containerd-202404.16.0",
      "nodeLabels": null,
      "nodePublicIpPrefixId": null,
      "nodeTaints": null,
      "orchestratorVersion": "1.28",
      "osDiskSizeGb": 128,
      "osDiskType": "Managed",
      "osSku": "Ubuntu",
      "osType": "Linux",
      "podSubnetId": null,
      "powerState": {
        "code": "Running"
      },
      "provisioningState": "Succeeded",
      "proximityPlacementGroupId": null,
      "scaleDownMode": null,
      "scaleSetEvictionPolicy": null,
      "scaleSetPriority": null,
      "spotMaxPrice": null,
      "tags": null,
      "type": "VirtualMachineScaleSets",
      "upgradeSettings": {
        "drainTimeoutInMinutes": null,
        "maxSurge": "10%",
        "nodeSoakDurationInMinutes": null
      },
      "vmSize": "Standard_D2s_v3",
      "vnetSubnetId": null,
      "windowsProfile": null,
      "workloadRuntime": null
    }
  ],
  "apiServerAccessProfile": null,
  "autoScalerProfile": null,
  "autoUpgradeProfile": {
    "nodeOsUpgradeChannel": "NodeImage",
    "upgradeChannel": null
  },
  "azureMonitorProfile": null,
  "azurePortalFqdn": "luxekube-networkwatcherrg-4ebf42-3ys90dgs.portal.hcp.eastus2.azmk8s.io",
  "currentKubernetesVersion": "1.28.9",
  "disableLocalAccounts": false,
  "diskEncryptionSetId": null,
  "dnsPrefix": "luxekube-NetworkWatcherRG-4ebf42",
  "enablePodSecurityPolicy": null,
  "enableRbac": true,
  "extendedLocation": null,
  "fqdn": "luxekube-networkwatcherrg-4ebf42-3ys90dgs.hcp.eastus2.azmk8s.io",
  "fqdnSubdomain": null,
  "httpProxyConfig": null,
  "id": "/subscriptions/4ebf4283-e95c-4bff-8fe2-5b536d1c8d70/resourcegroups/NetworkWatcherRG/providers/Microsoft.ContainerService/managedClusters/luxekube",
  "identity": {
    "delegatedResources": null,
    "principalId": "3e076bcc-2690-412d-b3df-87ffa2e1b795",
    "tenantId": "57543043-e835-409c-ad0b-9f3b46924a55",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
  },
  "identityProfile": {
    "kubeletidentity": {
      "clientId": "45a2f305-8275-4573-a5e4-9ed993f93dba",
      "objectId": "da5161ee-0514-4110-880c-86dcf7641dfb",
      "resourceId": "/subscriptions/4ebf4283-e95c-4bff-8fe2-5b536d1c8d70/resourcegroups/MC_NetworkWatcherRG_luxekube_eastus2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/luxekube-agentpool"
    }
  },
  "ingressProfile": null,
  "kubernetesVersion": "1.28",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDM215i5j33AEkI5xY2bdCFLtwdZK8eC2IgtiHjMaOiUageby3qL7TIs2Dqc0K9UvjepGI28HOYELOr7v3TCTjR1nw8jbS4JbatZ5HjE5Ev5jXFidKJu4nl3YqlellkVj0+ZyxSWcKTzk3B5UuRHy8OxsNAef0vzQSsTHbh2CClkw2XyI30FqXwe4l+QY7kzaDgcBmWDR9UYLXwStyJAxGkcMgQOBLtwz5IplqnFrV36O5SwZkk6zihsaAyjfKWDan4Ma6qcKxTx290jkPgGw1FXWQAOvibByBl3giaRUEnz/XIkOUdCHNPDLKscAXVM3escqJSxkzwnp3g+l5mQwwTknH6v6lN0FQQgiGc176foO6j2oTiTxZ4oOX52GjIOKPPK2MK4ZlG6R5/KparTlRxu6SSL6n9gkyX3zifrLmDxj0FqSOOvR0LMC/abDwIYMcejx6uOAIahFVSzFcTj7AczhLnhjcVj8Hrs61R0tTFSvNp3+0MW1RgpGu11FGg3UUivt4N2SZ6BoLP++tNFxM3nf21BuCnJIXh1MkdGkY4H4m5NyUa0ZkDtT6g1/HsIf46tUqudZPP/DR7hS7s19QQKvufefg7WHuJVSMzKrcRtOtDp+qj4Mwl2GuUOLqjoVO0i43VVuTW1fjz0hdGdDxfhCIxgzhL0MndMJxNIEtTdQ== gradx@bluedevil\n"
        }
      ]
    }
  },
  "location": "eastus2",
  "maxAgentPools": 100,
  "metricsProfile": {
    "costAnalysis": {
      "enabled": false
    }
  },
  "name": "luxekube",
  "networkProfile": {
    "dnsServiceIp": "10.0.0.10",
    "ipFamilies": [
      "IPv4"
    ],
    "loadBalancerProfile": {
      "allocatedOutboundPorts": null,
      "backendPoolType": "nodeIPConfiguration",
      "effectiveOutboundIPs": [
        {
          "id": "/subscriptions/4ebf4283-e95c-4bff-8fe2-5b536d1c8d70/resourceGroups/MC_NetworkWatcherRG_luxekube_eastus2/providers/Microsoft.Network/publicIPAddresses/2d4a7240-0d9d-404d-9af1-a6dd1bb3ccfb",
          "resourceGroup": "MC_NetworkWatcherRG_luxekube_eastus2"
        }
      ],
      "enableMultipleStandardLoadBalancers": null,
      "idleTimeoutInMinutes": null,
      "managedOutboundIPs": {
        "count": 1,
        "countIpv6": null
      },
      "outboundIPs": null,
      "outboundIpPrefixes": null
    },
    "loadBalancerSku": "standard",
    "natGatewayProfile": null,
    "networkDataplane": "azure",
    "networkMode": null,
    "networkPlugin": "azure",
    "networkPluginMode": null,
    "networkPolicy": null,
    "outboundType": "loadBalancer",
    "podCidr": null,
    "podCidrs": null,
    "serviceCidr": "10.0.0.0/16",
    "serviceCidrs": [
      "10.0.0.0/16"
    ]
  },
  "nodeResourceGroup": "MC_NetworkWatcherRG_luxekube_eastus2",
  "oidcIssuerProfile": {
    "enabled": true,
    "issuerUrl": "https://eastus2.oic.prod-aks.azure.com/57543043-e835-409c-ad0b-9f3b46924a55/c380cd28-329d-415a-9c8e-2efccd5b40c1/"
  },
  "podIdentityProfile": null,
  "powerState": {
    "code": "Running"
  },
  "privateFqdn": null,
  "privateLinkResources": null,
  "provisioningState": "Succeeded",
  "publicNetworkAccess": null,
  "resourceGroup": "NetworkWatcherRG",
  "resourceUid": "663c30bcd9406d0001c37acd",
  "securityProfile": {
    "azureKeyVaultKms": null,
    "defender": null,
    "imageCleaner": null,
    "workloadIdentity": {
      "enabled": true
    }
  },
  "serviceMeshProfile": null,
  "servicePrincipalProfile": {
    "clientId": "msi",
    "secret": null
  },
  "sku": {
    "name": "Base",
    "tier": "Free"
  },
  "storageProfile": {
    "blobCsiDriver": null,
    "diskCsiDriver": {
      "enabled": true
    },
    "fileCsiDriver": {
      "enabled": true
    },
    "snapshotController": {
      "enabled": true
    }
  },
  "supportPlan": "KubernetesOfficial",
  "systemData": null,
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters",
  "upgradeSettings": null,
  "windowsProfile": {
    "adminPassword": null,
    "adminUsername": "azureuser",
    "enableCsiProxy": true,
    "gmsaProfile": null,
    "licenseType": null
  },
  "workloadAutoScalerProfile": {
    "keda": null,
    "verticalPodAutoscaler": null
  }
}


az login
az account set --subscription Yearly


#### Use Azure role-based access control for Kubernetes Authorization
#### https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac

### ??? az aks update --name luxekube --resource-group NetworkWatcherRG --subscription Yearly --enable-aad --aad-admin-group-object-ids 65e4b1b3-ccc2-4697-bf33-d006405c6a88


az aks get-credentials --resource-group NetworkWatcherRG --name luxekube 
kubelogin convert-kubeconfig -l azurecli

az aks update -g NetworkWatcherRG -n luxekube --enable-azure-rbac

AKS_ID=$(az aks show -g NetworkWatcherRG -n luxekube --query id -o tsv)

az role assignment create --role "Azure Kubernetes Service RBAC Admin" --assignee d4d3a19f-bae0-481f-af83-e479118c2e1c --scope $AKS_ID
az aks get-credentials --resource-group NetworkWatcherRG --name luxekube 
kubectl get pods

#### Use the Azure Key Vault provider for Secrets Store CSI Driver in an Azure Kubernetes Service (AKS) cluster
#### https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver

az keyvault update  --name luxe --resource-group NetworkWatcherRG --subscription Yearly --enable-rbac-authorization


#### Connect your Azure identity provider to the Azure Key Vault Secrets Store CSI Driver in Azure Kubernetes Service (AKS)
#### https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access


#### Access with managed identity
az aks show -g NetworkWatcherRG -n luxekube --query addonProfiles.azureKeyvaultSecretsProvider -o tsv
az aks show -g NetworkWatcherRG -n luxekube --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId -o tsv
az aks show -g NetworkWatcherRG -n luxekube --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv

az identity create -g NetworkWatcherRG -n luxeidentity --subscription Yearly


export USER_ASSIGNED_CLIENT_ID="$(az aks show -g NetworkWatcherRG -n luxekube --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)"
export IDENTITY_OBJECT_ID="$(az aks show -g NetworkWatcherRG -n luxekube --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId -o tsv)"
export KEYVAULT_SCOPE=$(az keyvault show --name luxe --query id -o tsv)


az role assignment create --role "Key Vault Certificate User" --assignee $USER_ASSIGNED_CLIENT_ID --scope $KEYVAULT_SCOPE
az role assignment create --role "Key Vault Secrets User" --assignee $USER_ASSIGNED_CLIENT_ID --scope $KEYVAULT_SCOPE
az role assignment create --role "Key Vault Crypto User" --assignee $USER_ASSIGNED_CLIENT_ID --scope $KEYVAULT_SCOPE


kubectl apply -f secret-provider.yaml
kubectl delete pod busybox-secrets-store-inline-user-msi
kubectl apply -f busybox.yaml
kubectl describe pod busybox-secrets-store-inline-user-msi

base64 -d luxeCandy > luxeCandy64
openssl pkcs12 -in luxeCandy64 --nocerts -nodes -out luxeCandy64.key --password pass:"" --legacy

base64 -d luxePod > luxePod64
openssl pkcs12 -in luxePod64 --nocerts -nodes -out luxePod64.key --password pass:"" --legacy

