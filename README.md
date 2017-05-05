### Demo perceptyx setup

Dependencies:  
- Docker
- make
- awscli
- ansible
- ssh-keygen

## Synopsis

The code in this repository provisions an autoscaling ECS cluster in a VPC on AWS. Part of this design involves 2 separate load balancers, one public-facing ELB that listens for incoming HTTP traffic and forwards it onto a container that uses NGiNX to proxy connections to a simple Go application. An additional internal load balancer is used as a service endpoint for a MySQL container.

The MySQL container is bootstrapped with a test database schema which is imported at start-up.

Environment variables are maintained by an environment file in S3. An environment agent runs in a container on every ECS instance and reads the contents of the environment file every 30 seconds. The contents are placed in a Docker volume that all other containers mount in read-only mode.

In it's current form, the web container (NGiNX + Go) can be autoscaled as needed by adjusting the autoscaling properties on the application autoscaler and autoscaling group.

This project uses a combination of Ansible and CloudFormation to provision the AWS resources. CloudFormation handles most of the heavy lifting because Ansible's ECS support is limited.

## Setup

1. Enter the `ansible` directory and create an SSH keypair. The name of the key is important -- if it's changed, update `keypair_ecf.yaml` to match: `cd ansible && ssh-keygen -t rsa -b 4096 -f perceptyx_rsa`

2. Export the AWS access key and secret key of an IAM user with full access to provision AWS resources (or set as the default profile in `~/.aws/credentials`)

3. Create an initial environment file named `environ-dev` to configure the MySQL password and app environment:  
```
echo "APP_ENV=dev  
MYSQL_ROOT_PASSWORD=demodemo" > environ-dev
```

4. Run `ansible-playbook keypair_ecr.yaml` to import the keypair to AWS, provision 4 ECR repositories, and publish the initial environment file to S3

5. Return to the root of the repository and run `make build-all` to build the Docker images. This step downloads and builds the images for MySQL, NGiNX, and the Go toolchain. Afterwards, the Go source is compiled and baked into the web container.

6. Push the images to the ECRs created in step 4. Due to the formatting of AWS' ECR URLs, the AWS AccountId and Region are required: `make AWSAccountId=<AWS account ID> AWSRegion=<AWS region, i.e. us-east-1>) push-all`

7. Provision the ECS cluster with: `cd ansible && ansible-playbook -v cloudformation.yml`

Upon completion, the `cloudformation.yml` playbook will extract the MySQL load balancer DNS name from the stack outputs and update the S3 configuration environment to provide a very basic implementation of service discovery.

The external load balancer can be seen in the output as `PublicLoadBalancerDNSName` -- browsing to that URL will display the results from the MySQL query.



