# Clone source code to workspace
git clone https://github.com/thanhphuong0908/phuongnnt1-udacity-cloud-devops-project-3.git
git config --global user.name "thanhphuong0908"
git config --global user.email thanhphuong09081999@gmail.com

# Connect to AWS
aws configure
aws configure set aws_session_token xxx

# Create AWS ECR using AWS Console
# Create AWS Codebuild Project using AWS Console
AWS_DEFAULT_REGION us-east-1
AWS_ACCOUNT_ID 364810126671
IMAGE_REPO_NAME phuongnnt1-repo
IMAGE_TAG 1.0.1
AWS_ACCESS_KEY_ID xxx
AWS_SECRET_ACCESS_KEY xxx
AWS_SESSION_TOKEN xxx
AWS_REGION us-east-1

# Create EKS Cluster and Node Group
eksctl create cluster --name phuongnnt1-cluster --version 1.25 --region us-east-1 --nodegroup-name phuongnnt1-nodegroup --node-type t3.medium --nodes 2
<!-- eksctl create cluster --name phuongnnt1-cluster --region us-east-1 --version 1.27 --vpc-private-subnets subnet-03580e5106eb03120,subnet-051ffa44d3d7a85d9 --without-nodegroup -->
# Delete EKS Cluster and Node Group
eksctl delete nodegroup --cluster=phuongnnt1-cluster --name=phuongnnt1-nodegroup
eksctl delete cluster --name=phuongnnt1-cluster
# Connect to EKS cluster
aws eks update-kubeconfig --region us-east-1 --name phuongnnt1-cluster
# Install PostgresQL using helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install postgresql bitnami/postgresql --set primary.persistence.enabled=false --set readReplicas.persistence.enabled=false
# export postgres password
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
echo $POSTGRES_PASSWORD
