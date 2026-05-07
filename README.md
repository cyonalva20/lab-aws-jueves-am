## SSO AWS

```
aws configure sso
```


```
aws sts get-caller-identity --profile mi-perfil
```


## Gitflow seguido

### Estructura de ramas

```
main        
develop     
├── feature/upload-lambda
├── feature/crop-lambda
├── feature/mod-networking
├── feature/mod-s3
├── feature/mod-sqs
├── feature/mod-lambda
├── feature/mod-api-gateway
├── feature/mod-observability
├── feature/mod-root
└── feature/aws
```

### Comandos ejecutados

```

git checkout -b develop
git push -u origin develop

# Upload Lambda
git checkout -b feature/upload-lambda
git add .
git commit -m "feat: creacion upload-lambda"
git checkout develop
git merge feature/upload-lambda
git branch -d feature/upload-lambda
git push origin develop

# Crop Lambda
git checkout -b feature/crop-lambda
git add .
git commit -m "feat: creacion crop-lambda"
git checkout develop
git merge feature/crop-lambda
git branch -d feature/crop-lambda
git push origin develop

# Variables
git checkout -b feature/var-tf
git add .
git commit -m "infra: creacion de variables y environments de tf"
git checkout develop
git merge feature/var-tf
git branch -d feature/var-tf
git push origin develop

# Networking
git checkout -b feature/mod-networking
git add .
git commit -m "infra: creacion modulo networking"
git checkout develop
git merge feature/mod-networking
git branch -d feature/mod-networking
git push origin develop

# S3
git checkout -b feature/mod-s3
git add .
git commit -m "infra: creacion modulo s3"
git checkout develop
git merge feature/mod-s3
git branch -d feature/mod-s3
git push origin develop

# SQS
git checkout -b feature/mod-sqs
git add .
git commit -m "infra: creacion del modulo sqs"
git checkout develop
git merge feature/mod-sqs
git branch -d feature/mod-sqs
git push origin develop

# Lambda
git checkout -b feature/mod-lambda
git add .
git commit -m "infra: creacion del modulo lambda"
git checkout develop
git merge feature/mod-lambda
git branch -d feature/mod-lambda
git push origin develop

# API Gateway
git checkout -b feature/mod-api-gateway
git add .
git commit -m "infra: creacion de mudulo api gateway"
git checkout develop
git merge feature/mod-api-gateway
git branch -d feature/mod-api-gateway
git push origin develop

# Observability
git checkout -b feature/mod-observability
git add .
git commit -m "infra: creacion del modulo de observability"
git checkout develop
git merge feature/mod-observability
git branch -d feature/mod-observability
git push origin develop

# Root orquestador
git checkout -b feature/iac-root
git add .
git commit -m "infra: orquestador conectado a todos los modulos"
git checkout develop
git merge feature/iac-root
git branch -d feature/iac-root
git push origin develop

# AWS
git checkout -b docs/readme
git add README.md
git commit -m "docs: add full project documentation"
git checkout develop
git merge docs/readme
git branch -d docs/readme
git push origin develop

```

## Instalación de dependencias

```
# Upload Lambda
cd src/upload-lambda
npm install
cd ../..

# Crop Lambda
cd src/crop-lambda
npm install --os=linux --cpu=x64 sharp
cd ../..
```

## Inicializar Terraform

```
cd iac
terraform init
```

Crear workspaces para cada entorno:

```
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod
```

## Despliegue DEV

```
cd iac
terraform workspace select dev
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

Outputs DEV:
```
api_endpoint         = "https://qn7zyvkbdh.execute-api.us-east-1.amazonaws.com/upload"
bucket_name          = "image-processor-dev-images-099090990554"
cloudwatch_dashboard = "image-processor-dev-dashboard"
crop_lambda_name     = "image-processor-dev-crop"
environment          = "dev"
upload_lambda_name   = "image-processor-dev-upload"
```

Probar DEV:
```
curl -X POST https://qn7zyvkbdh.execute-api.us-east-1.amazonaws.com/upload -F "file=@ruta/a/imagen.jpg"
```

## Despliegue QA

```
cd iac
terraform workspace select qa
terraform plan -var-file="environments/qa.tfvars"
terraform apply -var-file="environments/qa.tfvars"
```

```
api_endpoint         = "https://ed75bf85be.execute-api.us-east-1.amazonaws.com/upload"
bucket_name          = "image-processor-qa-images-099090990554"
cloudwatch_dashboard = "image-processor-qa-dashboard"
crop_lambda_name     = "image-processor-qa-crop"
environment          = "qa"
upload_lambda_name   = "image-processor-qa-upload"
```

Probar QA:
```
curl -X POST https://ed75bf85be.execute-api.us-east-1.amazonaws.com/upload -F "file=@ruta/a/imagen.jpg"
```

## Despliegue PROD

AWS tiene un límite de 5 Elastic IPs por región. Como DEV y QA
usan 4 EIPs (2 cada uno), es necesario destruir DEV antes de desplegar PROD.

### Destruir DEV para liberar EIPs

```
cd iac
terraform workspace select dev
terraform destroy -var-file="environments/dev.tfvars"
```

### Desplegar PROD

```
terraform workspace select prod
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

Outputs PROD:
```
api_endpoint         = "https://kb40a9ai2l.execute-api.us-east-1.amazonaws.com/upload"
bucket_name          = "image-processor-prod-images-099090990554"
cloudwatch_dashboard = "image-processor-prod-dashboard"
crop_lambda_name     = "image-processor-prod-crop"
dlq_arn              = "arn:aws:sqs:us-east-1:099090990554:image-processor-prod-image-dlq"
environment          = "prod"
upload_lambda_name   = "image-processor-prod-upload"
```

Probar PROD:
```
curl -X POST https://kb40a9ai2l.execute-api.us-east-1.amazonaws.com/upload -F "file=@ruta/a/imagen.jpg"
```

## Destruir recursos

Destruir todos los entornos al finalizar:

```
# QA
cd iac
terraform workspace select qa
terraform destroy -var-file="environments/qa.tfvars"

# PROD
terraform workspace select prod
terraform destroy -var-file="environments/prod.tfvars"
```