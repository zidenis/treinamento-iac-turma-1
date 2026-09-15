# Criar Instância EC2 com IP público

Provisionar uma instância EC2 com IP público e acesso SSH liberado apenas para IP do usuário

## Login na AWS

Login na AWS usando aws cli:

```bash
aws login --profile treinamento  # Adicione flag --remote se estiver executando a partir de container
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

## Criar a VM EC2 com Terraform

Execute os comandos abaixo um de cada vez, atentando para as mensagens de saída:

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

# Saida esperada
# Outputs:

# instance_ip = "123.123.123.123"
```

## Validar a Atividade

- Verifique no console o status da instancia EC2
- Realize acesso SSH à instância EC2:

```bash
ssh -i iac-ssh-private-key.pem ubuntu@$(terraform output -raw instance_ip)
```

## Destruir os Recursos Utilizados

Ao final do treinamamento lembre-se de destruir os elementos criados

```bash
terraform destroy
```

## Troubleshooting

### Error No valid credential sources found

Ao executar algum comando terraform, você pode eventualmente ter esse erro.

```log
│ Error: No valid credential sources found
│
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on provider.tf line 1, in provider "aws":
│    1: provider "aws" {
│
│ Please see https://registry.terraform.io/providers/hashicorp/aws
│ for more information about providing credentials.
│
│ Error: failed to refresh cached credentials, create oauth2 token: operation error Signin: CreateOAuth2Token, https response error StatusCode: 400, RequestID:
│ X-Amzn-Trace-Id=Root=xxxxxxxxxxxxxx;RequestId=xxxxxxxxxxxxxxxxx, ValidationException: The provided authorization grant is invalid, expired, revoked, or
│ malformed
```

Solução: Execute o comando para verificar se o aws cli está devidamente configurado e tente novamente:

```bash
aws sts get-caller-identity
```
