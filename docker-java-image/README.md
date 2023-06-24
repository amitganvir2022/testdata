## Dockerfile

# TO create docker images on local ####
```
cd CREATE-JAVA-APP-DOCKER-IMAGE
dos2unix *
docker build . -t amitrepo/hello2java:0.0.1
```


#Follow below steps to create docker image on minikube machine ####
```
cd CREATE-JAVA-APP-DOCKER-IMAGE
dos2unix *
```

for root user
```
repo=$(pwd)
minikube ssh "cd $repo; docker build . -t amitrepo/hello2java:0.0.1"
```

for non-root user
```
repo=$(pwd)
repo=$(echo $repo|sed 's/home/hosthome/')
minikube ssh "cd $repo; docker build . -t amitrepo/hello2java:0.0.1"
```
