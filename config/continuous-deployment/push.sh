#!/bin/sh

setup_git() {
  echo "Setting up git account"
  git config --global user.email "mareak@mareak.com"
  git config --global user.name "Mareak"
  echo "Done ..."
}

setup_dockerhub(){
  echo "Setting up docker account"
  docker login -u mareak -p ${DOCKER_PWD}
  echo "Done ..."
}

checkout() {
  echo -e "\nCheckout master"
  git checkout -b master
  git remote add origin-pages https://Mareak:${TOKEN}@github.com/Mareak/webscrapping.git
  echo "Done ..."
}

tag() {
  echo -e "\nAdd release tag"
  export tag_incr='v1.'$((${TAG:3}+1))
  git tag $tag_incr
  echo "Done ..."
}

versionning() {
  echo -e "\nPulling from master"
  #pull from master just in case of conflict
  git pull origin-pages master
  echo "Done ..."
  
  echo -e "\nIncrement version"
  sed -i -r 's/v1\.\w+/'${tag_incr}'/g' templates/*
  git commit -am $tag_incr
  echo "Done ..."
}

merge_code() {
  echo -e "\nMerge on github"
  git push origin-pages $tag_incr
  git push origin-pages master
  echo "Done ..."
}

create_images(){
  echo -e "\nCreate images to deploy"
  docker build -t mareak/webscrapping_webscrapping:$tag_incr -f ./config/docker/Dockerfile.webscrapping .
  docker build -t mareak/webscrapping_nginx:$tag_incr -f ./config/docker/Dockerfile.nginx .
  echo "Sucess"
}

push_images_dockerhub(){
  echo -e "\nPush new image to dockerhub"
  docker push mareak/webscrapping_webscrapping:$tag_incr
  docker push mareak/webscrapping_nginx:$tag_incr
  echo "Success"
}

setup_az_image_registry() {
  echo -e "Setting up azure docker registry account"
  docker login MareackR.azurecr.io -u ${AZURE_USERNAME_REG} -p ${AZURE_PASSWORD_REG}
  echo "Done ..."
}

push_image_azure() {
  echo -e "Push"
  docker tag webscrapping_deploy:latest MareackR.azurecr.io/webscrapping_deploy:$tag_incr 
  docker push MareackR.azurecr.io/webscrapping_deploy:$tag_incr
  echo "Done ..."
}

setup_git
setup_dockerhub
checkout
tag
versionning
merge_code
create_images
push_images_dockerhub
