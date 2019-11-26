#!/bin/sh

export() {
	#Login to azure
	az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
	az account set --subscription=$ARM_SUBSCRIPTION_ID
	az aks get-credentials --resource-group $AZ_RG_K8S --name $AZ_CLUSTERNAME_K8S
    
    #Delete old pods, services
    kubectl delete po,svc  --all
	
    #Change version and tag
	cd ./config/continuous-deployment/kurbernetes/
	sed -i "s/ENV_MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/g" mariadb-deploy.yml 
	sed -i "s/ENV_MYSQL_DATABASE/$MYSQL_DATABASE/g" mariadb-deploy.yml webscrapping-deploy.yml
	sed -i "s/ENV_MYSQL_USER/$MYSQL_USER/g" mariadb-deploy.yml webscrapping-deploy.yml
	sed -i "s/ENV_MYSQL_PASSWORD/$MYSQL_PASSWORD/g" mariadb-deploy.yml webscrapping-deploy.yml
	sed -i "s/ENV_SECRET_KEY/$SECRET_KEY/g" webscrapping-deploy.yml
	sed -i "s/ENV_TAG/$TAG/g" webscrapping-deploy.yml nginx-deploy.yml mariadb-deploy.yml
	sed -i "s/ENV_AZURE_SERVER_REG/$AZURE_SERVER_REG/g" webscrapping-deploy.yml nginx-deploy.yml mariadb-deploy.yml

	#Change version
	kubectl apply -f .

	#Bug
	sleep 200
    kubectl delete pod $(kubectl get pods | awk '/webscrapping/ {print $1;exit}')
	sleep 30
}

export
