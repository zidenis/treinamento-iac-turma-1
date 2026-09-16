# Provisionar ALB e instância EC2 com Nginx

Provisionar uma instância EC2 com Nginx e um ALB para expor serviço para internet usando certificado criado na atividade de Stack Edge Setup.

## Login na AWS

Login na AWS usando aws cli:

```bash
aws login --profile treinamento
# Complete o login pelo browser
```

Configuração do profile e validação:

```bash
export AWS_PROFILE="treinamento"

aws sts get-caller-identity
# Exemplo de resulltado esperado:
# {
#     "UserId": "AIDA4ZAXWAWAZACYXNXJC",
#     "UserId": "XXXXXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/nome.sobrenome@trtxx.jus.br"
# }
```

## Criar a VM EC2 e o ALB com Terraform

Crie um arquivo `terraform/terraform.tfvars` adicionando o ARN do Certificado criado na atividade de Stack Edge Setup

```bash
certificate_arn = "arn:aws:acm:region:account-id:certificate/certificate-id" # Replace with your ACM ARN
```

Em seguida, execute os comandos abaixo um de cada vez, atentando para as mensagens de saída:

```bash
pwd      # Esteja na pasta raiz do treinamento

cd dia-4/4.01-ALB-EC2-nginx/terraform/
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

# Tempo estimado: 3 minutos

# Saida esperada
# Outputs:

# alb_dns_name = "nginx-alb-9999999999.us-east-1.elb.amazonaws.com"
```

## Validar a Atividade

- Verifique no console o status da instancia EC2 e do ALB
- Acesse no Browser o endereço contido na output `alb_dns_name`
