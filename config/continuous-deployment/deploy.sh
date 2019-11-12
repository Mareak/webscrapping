#!/bin/sh

export() {
	az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
	az account set --subscription=$ARM_SUBSCRIPTION_ID
	terraform init
    TAG='v1.'$((${TAG:3}+1))
	terraform apply -var TAG=$TAG -var AZURE_USERNAME_REG=$AZURE_USERNAME_REG -var AZURE_PASSWORD_REG=$AZURE_PASSWORD_REG -var AZURE_SERVER_REG=$AZURE_SERVER_REG -auto-approve
}

export
