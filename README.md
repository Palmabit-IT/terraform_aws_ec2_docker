# Terraform AWS EC2 Docker

Terraform to setup an AWS EC2 instance with docker and gitlab user for CI

## Prerequisites

* Terraform v0.12.9 - [https://www.terraform.io/](https://www.terraform.io/)

## Environment variables (optional)

Example:

```
export AWS_ACCOUNT_ID=123456789012
export AWS_ACCESS_KEY_ID=ABCD...
export AWS_SECRET_ACCESS_KEY=abcd...
export AWS_REGION=eu_west1
```

## How to run

### Init

```
$  terraform init
```

### Show validate

```
$  terraform validate
```

### Create plan

```
$  terraform plan -out=tfplan -input=false 
    -var "ec2_name=production"
    -var "aws_account_id=${AWS_ACCOUNT_ID}"
    -var "access_key=${AWS_ACCESS_KEY_ID}"
    -var "secret_key=${AWS_SECRET_ACCESS_KEY}"
    -var "region=${AWS_REGION}"   
```

For other variables see [variables.tf](variables.tf)

### Show plan

```
$  terraform show
```

### Execute plan

```
$  terraform apply tfplan
```

If the EC2 instance already exists when you add these lines you will need to run

```
$  terraform refresh
```

### Destroy

```
$  terraform destroy -input=false 
    -var "ec2_name=production"
    -var "aws_account_id=${AWS_ACCOUNT_ID}"
    -var "access_key=${AWS_ACCESS_KEY_ID}"
    -var "secret_key=${AWS_SECRET_ACCESS_KEY}"
    -var "region=${AWS_REGION}"
```
