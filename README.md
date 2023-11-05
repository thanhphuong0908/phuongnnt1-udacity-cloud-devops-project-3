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
# Delete EKS Cluster and Node Group
eksctl delete nodegroup --cluster=phuongnnt1-cluster --name=phuongnnt1-nodegroup
eksctl delete cluster --name=phuongnnt1-cluster
# Connect to EKS cluster
aws eks update-kubeconfig --region us-east-1 --name phuongnnt1-cluster
# Install cloudwatch container insight
ClusterName=phuongnnt1-cluster
RegionName=us-east-1
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -
# Install PostgresQL using helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install postgresql bitnami/postgresql --set primary.persistence.enabled=false --set readReplicas.persistence.enabled=false
# export postgres password
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
echo $POSTGRES_PASSWORD
# install postgresql-client
sudo apt-get update
sudo apt-get install postgresql-client -y
# run postgresql seed files
kubectl port-forward --namespace default svc/postgresql 5432:5432 &
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/1_create_tables.sql
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/2_seed_users.sql
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < ./db/3_seed_tokens.sql
# deploy application
kubectl apply -f ./deployment