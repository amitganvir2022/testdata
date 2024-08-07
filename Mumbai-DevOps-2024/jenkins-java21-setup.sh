################ Step1: Goto Jenkins ec2 and install Java 21
sudo su -     ## login with root
apt-get update
apt-get install openjdk-21-jre -y
apt-get install openjdk-21-jdk -y

#apt install default-jdk -y (#java11)
#apt install default-jre -y (#java11)
#echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"' >> /etc/environment

echo 'JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"' >> /etc/environment
source /etc/environment
echo $JAVA_HOME
java --version

################ Step2: Goto Jenkins ec2 - nstall Jenkins use Link for updated steps https://www.jenkins.io/doc/book/installing/linux/
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  
sudo apt-get update
sudo apt-get install jenkins -y
ps -ef | grep jenkins
service jenkins status

################ Step3: Open incase if its not opening allow port in Security Group
#Open your brower and use your ec2 public IP with port 8080
- http://<ec2-ip>:8080

################ Goto Jenkins ece - Use your password for Administrator password
cat /var/lib/jenkins/secrets/initialAdminPassword

##Jenkins intial setup
- Select Click on [Install Suggested Plugin]
- After above step, Create First Admin User (Set username/password for example, admin/admin) and Click on  [save & continue]
- Instance Configuration Click on  [save and Finish]
- Jenkins is ready! Click on [Start Using Jenkins]

## use below method to fix bug and improve basic funcationality
- Click on [Manage Jenkins] -> [Security] -> select/mark check box for CSRF Protection [*] Enable proxy compatibility
- Click on [Manage Jenkins] -> [System Configuration] [10] # of executors. To incress executors


## On Jenkins ec2
sudo su -
echo 'JENKINS_HOME="/var/lib/jenkins/"' >> /etc/environment
source /etc/environment
echo $JENKINS_HOME

##########################################################################################################################################################



############ how to run kubernetes container form Jekins Job  ################################################################################################
############ Step1: Goto Master ec2 and copy content of below file #It is for k8s cluster access
cat /etc/kubernetes/admin.conf 

############ Step2: Got to Jenkins ec2 #It is for k8s cluster access
sudo su -
su - jenkins
mkdir ~/.kube
## Paste admin.conf file contente here
vim ~/.kube/config
exit

############ Step3: Got Jenkions ec2 and Install kubeclt
sudo su -
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common  -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
wget -q -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo deb http://apt.kubernetes.io/ kubernetes-xenial main | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install kubectl=1.21.1-00 -y

############ step 4: Allow sudo access for Jenkins
sudo su -
echo "jenkins ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

############ Step5: Create free-stype job and execute kubectl  for example -> kubectl run nginx --image=nginx

############ Step6: Run your job
####################################################################################################################################

############ how to compile java code using maven form Jekins Job  ############
sudo su -
apt install maven -y

## use below command on jenkins jobs UI
user your own repod  https://github.com/amitganvir23/hello_maven.git
cd lcd
mvn clean
mvn compile
mvn package

cd lcd
ls
mvn clean
mvn compile
mvn package

DOCKER_USERNAME=amitganvir6
DOCKER_PASSWORD="dckr_pat_FtkB8x_xWiGc9KQ6EqjRgwGbe3o"
sudo docker login -u $DOCKER_USERNAME -p${DOCKER_PASSWORD}
cp target/lcd-*-SNAPSHOT.jar lcd.jar

### replace lcd with your name
sudo docker build . -t "$DOCKER_USERNAME/lcd:v${BUILD_NUMBER}"
sudo docker push $DOCKER_USERNAME/lcd:v${BUILD_NUMBER}

kubectl run lcd --image=amitganvir6/lcd:v${BUILD_NUMBER} --dry-run=client -o yaml > pod.yaml
kubectl apply -f pod.yaml
kubectl expose pod lcd --type=NodePort --port=8082 --dry-run=client -o yaml > svc.yaml
kubectl apply -f svc.yaml
kubectl get svc lcd
################################################################################################################################################
