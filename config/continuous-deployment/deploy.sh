#!/bin/sh

export() {
	az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
	az account set --subscription=$ARM_SUBSCRIPTION_ID
	#terraform init
    #TAG='v1.'$((${TAG:3}+1))
	#terraform apply -var TAG=$TAG -var AZURE_USERNAME_REG=$AZURE_USERNAME_REG -var AZURE_PASSWORD_REG=$AZURE_PASSWORD_REG -var AZURE_SERVER_REG=$AZURE_SERVER_REG -auto-approve
	az aks get-credentials --resource-group $AZ_RG_K8S --name $AZ_CLUSTERNAME_K8S
    kubectl delete po,svc  --all
	
	cd ./config/continuous-deployment/kurbernetes/
	sed -ie "s/ENV_MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/g" mariadb-deploy.yml 
	sed -ie "s/ENV_MYSQL_DATABASE/$MYSQL_DATABASE/g" mariadb-deploy.yml webscrapping-deploy.yml
	sed -ie "s/ENV_MYSQL_USER/$MYSQL_USER/g" mariadb-deploy.yml webscrapping-deploy.yml
	sed -ie "s/ENV_MYSQL_PASSWORD/$MYSQL_PASSWORD/g" mariadb-deploy.yml webscrapping-deploy.yml
	sed -ie "s/ENV_SECRET_KEY/$SECRET_KEY/g" webscrapping-deploy.yml
	sed -ie "s/ENV_TAG/$TAG/g" webscrapping-deploy.yml nginx-deploy.yml
	sed -ie "s/ENV_AZURE_SERVER_REG/$AZURE_SERVER_REG/g" webscrapping-deploy.yml nginx-deploy.yml

	kubectl apply -f .
	sleep 10
    kubectl cp . $(kubectl get pods | awk '/mariadb/ {print $1;exit}'):/test
}

export
