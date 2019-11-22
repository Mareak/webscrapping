#!/bin/sh

export() {
	az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
	az account set --subscription=$ARM_SUBSCRIPTION_ID
    cd ./config/continuous-deployment/
	#terraform init
    #TAG='v1.'$((${TAG:3}+1))
	#terraform apply -var TAG=$TAG -var AZURE_USERNAME_REG=$AZURE_USERNAME_REG -var AZURE_PASSWORD_REG=$AZURE_PASSWORD_REG -var AZURE_SERVER_REG=$AZURE_SERVER_REG -auto-approve
	az aks get-credentials --resource-group $AZ_RG_K8S --name $AZ_CLUSTERNAME_K8S
    kubectl delete po,svc  --all
	
    sed -i 's/${MYSQL_ROOT_PASSWORD}/'$MYSQL_ROOT_PASSWORD'/g' config/continuous-deployment/kurbernetes/mariadb-deploy.yml 
    sed -i 's/${MYSQL_DATABASE}/'$MYSQL_DATABASE'/g' config/continuous-deployment/kurbernetes/mariadb-deploy.yml config/continuous-deployment/kurbernetes/webscrapping-deploy.yml
    sed -i 's/${MYSQL_USER}/'$MYSQL_USER'/g' config/continuous-deployment/kurbernetes/mariadb-deploy.yml config/continuous-deployment/kurbernetes/webscrapping-deploy.yml
    sed -i 's/${MYSQL_PASSWORD}/'$MYSQL_PASSWORD'/g' config/continuous-deployment/kurbernetes/mariadb-deploy.yml config/continuous-deployment/kurbernetes/webscrapping-deploy.yml
    sed -i 's/${SECRET_KEY}/'$SECRET_KEY'/g' config/continuous-deployment/kurbernetes/webscrapping-deploy.yml
    sed -i 's/${TAG}/'$TAG'/g' config/continuous-deployment/kurbernetes/webscrapping-deploy.yml config/continuous-deployment/kurbernetes/nginx-deploy.yml
    sed -i 's/${AZURE_SERVER_REG}/'$AZURE_SERVER_REG'/g' config/continuous-deployment/kurbernetes/webscrapping-deploy.yml config/continuous-deployment/kurbernetes/nginx-deploy.yml
	
	kubectl apply -f ./config/continuous-deployment/kurbernetes/
}

export
