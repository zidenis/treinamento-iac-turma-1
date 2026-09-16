# Criar Stacks Bootstrap e Landing Zone

Provisionar na conta de testes as stacks iniciais para uso do Iac/JT:

- Stack Bootstrap
- Stack Lading Zone

Para todas as etapas desta atividade usaremos a instância EC2 criada na [Atividade de Criação de Instância EC2 com IP Público](../../dia-1/1.11-ec2-ip-publico/README.md). Esta Instância já possui todas as ferramentas instaladas par uso do Iac/JT

## Conectar SSH a instancia EC2

Conecte via SSH à instância criada na atividade anterior:

```bash
cd ../../dia-1/AT_ec2_ip_publico/terraform

# Executar terraform apply para atualizar informação de IP publico
terraform apply

ssh -i iac-ssh-private-key.pem ubuntu@$(terraform output -raw instance_ip)
```

Após conexão todos as etapas seguintes serão executados como root. Para abrir uma sessão como root:

```bash
sudo -i
```

## Alternativa: Rodar comandos via container

Alternativamente, é possível executar os comandos deste lab via container:

```bash
# Iniciando container a partir de Linux com Docker
sudo docker run --privileged --rm -it \
-v "$(pwd):/treinamento" -v "$(pwd)/.aws:/home/iac/.aws"\
zidenis/treinamento-iac-nuvem-jt:2.2.0

# Iniciando container a partir de Windows com Podman
# podman run --privileged --rm -it -v "$(pwd -W):/treinamento" -v "$(pwd -W)/.aws:/home/iac/.aws" zidenis/treinamento-iac-nuvem-jt:2.2.0
```

Passos abaixo a partir do container:

```bash
tenv tf install 1.15.9
tenv tf use 1.15.9
tenv tg install 1.1.3
tenv tg use 1.1.3
export TG_PROVIDER_CACHE=1
export TG_PROVIDER_CACHE_DIR=/treinamento/.terragrunt-cache/terragrunt/providers
mkdir -pv $TG_PROVIDER_CACHE_DIR
```

## Preparar repositorio aws-live

```bash
# Comando para git armazenar credenciais
git config --global credential.helper store

# Ao realizar git clone inicial podem ser solicitadas credenciais do do git.pje.csjt
# Passe o seu usuario do gitlab (email) e no campo de password passe o PAT (Personal Access Token)
# Para gerar o PAT, no console do gitlab (Preferences --> Personal Access Token --> Add new Token, selecionar permissão write-repository)
git clone https://git.pje.csjt.jus.br/cloud/iac/projects/aws-live.git

cd aws-live

# Realizando checkout para a tag da versão desejada
git checkout v1.0.0-beta.4
```

## Realizar AWS Login via Maquina Remota

Para fazer login a partir de máquina remota basta adicionar a flag `--remote` ao comando.

```bash
aws login --profile treinamento --remote    # manter region  us-east-1
```

Prossiga com as orientações do prompt para concluir login.

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

## Inicializar Stack Bootstrap

A documentação completa da Stack Bootstrap para o operador de IAC está em <https://git.pje.csjt.jus.br/cloud/iac/projects/aws-live/-/blob/v1.0.0-beta.4/docs/02-operator-manual/bootstrap.md>

Ao consultar a documentação lembre-se sempre de ajustar para selecionar a tag da versão desejada.

### Preparar arquivos root.yaml e accounts.yaml

No arquivo `root.yaml`:

- Campo `region`: altere para `us-east-1`
- Campo `availability_zone_ids`: altere para `use1-az1` e `use1-az2`
- Campo `state_bucket_name`: indique o número seu tribunal e adicione o sufixo `trn-seu_nome-seu_sobrenome` para. Ex: `br-jus-jt-trt5-prd-s3-remote-state-trn-lucas-mendes`
- Campo `tags.organization`: indique o número do seu tribunal

No arquivo accounts.yaml:

- Comente a conta `producao` que não será utilizadas no treinamento. As contas utilizadas no treinamento serão `seguranca`, `nao-producao` e `redes`
- Altere os campos `trusted_user_arns` para constar somente o ARN do seu usuário (pode ser obtido com `aws sts get-caller-identity`)
- Altere as informações do numero do tribunal
- Altere os campos de `account_id` para apontar a conta usada no treinamento
- Altere a tag `environment` para `dev`

Exemplos de comandos de substituição usando `vim`. Digite `:` antes de cada comando para entrar no modo comando:

```vim
# Substituindo usuario foo.bla pelo seu
%s#arn:aws:iam::999999999999:user/foo.bla@trtXX.jus.br#arn:aws:iam::123456789012:user/nome.sobrenome@trtxx.jus.br#g

# Removendo usuario fulano.beltrano
%s#    - "arn:aws:iam::999999999999:user/fulano.beltranotrtXX.jus.br"##g

# Alterando o numero do tribunal, exemplo alterando de XX para 5:
%s/XX/5/g

# Alterando os account_id:
%s/account_id: "999999999999"/account_id: "123456789012"/g

# Alterando tags de environment para dev
%s/  environment:.*/  environment: "dev"/g
```

### Ajuste exclusivo para o treinamento: adaptação para single account

Considerando que no treinamento só teremos acesso a uma conta AWS, iremos fazer uma adaptação no código para que ele funcione com single account.

Altere o arquivo `root.hcl`, substituindo 

```hcl
all_account_ids = sort([for name, cfg in local.accounts_yaml : cfg.account_id])
```

por:

```hcl
all_account_ids = sort(distinct([for name, cfg in local.accounts_yaml : cfg.account_id]))
```


### Executar comandos para instanciar Stack Bootstrap

Num ambiente multi-account devem ser seguidas as etapas na seguinte ordem:

1. Executar bootstrap na conta de segurança
2. Executar bootstrap nas demais contas
3. Executar bootstrao na conta de segurança ajustando variavel `enable_member_root_access` para false

Por conta do ambiente de treinamento ser single-account só é necessário executar a primeira etapa.

Etapa 1: Criando os elementos básicos (bucket de S3, chave KMS e role `jt-role-terraform-execution`) na conta de segurança

```bash
cd conta-seguranca/_00_bootstrap

aws sts get-caller-identity           # verificar identidade, deve estar logado na conta de segurança
export AWS_DEFAULT_REGION="us-east-1" # caso não tenha sido configurada a região para o profile no arquivo de configuração (~/.aws/config)

terragrunt backend bootstrap       # cria bucket S3 de estado
terragrunt plan                    # Mostra plano de execução. 
terragrunt apply                   # cria CMK para o bucket S3 de estado e politicas de acesso
cd -                               # volta para pasta raiz aws-live
```

### Desativar units do bootstrap

Desative as units do bootstrap renomeando os arquivos `*/_00_bootstrap/terragrunt.hcl` para `*/_00_bootstrap/terragrunt.hcl.done`

```bash
find ./ -wholename "*/_00_bootstrap/terragrunt.hcl" -exec mv -v {} {}.done \;
```

## Inicializar Stack Landing Zone

A documentação completa da Stack Landing Zone para o operador de IAC está em <https://git.pje.csjt.jus.br/cloud/iac/modules/aws/-/blob/v1.0.0-beta.4/stacks/landing-zone/README.md>

Ao consultar a documentação lembre-se sempre de ajustar para selecionar a tag da versão desejada.

A Stack de Lading Zone contempla:

- Configuração do Cloudtrail com logs Centralizados via S3 replication em Bucket na conta de Segurança
- Bucket para Armazenar Access Logs aos demais buckets
- Configuração no Athena para visualização dos logs de Cloudtrail e Access Logs de S3


### Preparar arquivo stack.yaml

Ajuste o arquivo `conta-seguranca/_01_landing-zone/stack.yaml`:

- `log_central_bucket_config.object_lock_retention_days` : Defina para valor `1` para setar período de object lock de apenas 1 dia.
- `tags`: ajuste as tags para constar o numero do seu tribunal
- `s3_buckets_suffix`: indique as iniciais do seu nome, apenas para garantir buckets com nomes unicos.

### Executar comandos para instanciar Stack Landing Zone

No ambiente de produção é executada a Stack Landing Zone para todas as contas. Considerando que o ambiente de treinamento é single account vamos usar flags `--queue-exclude-dir` para excluir as demais contas dessa etapa.

```bash
pwd # apenas para checar que está na pasta raiz "aws-live"

# Plan
terragrunt run --all plan --queue-include-dir='**/_01_landing-zone/' --queue-exclude-dir='./conta-nao-producao/**' --queue-exclude-dir='./conta-producao/**' --queue-exclude-dir='./conta-redes/**'

# Apply
terragrunt run --all plan --queue-include-dir='**/_01_landing-zone/' --queue-exclude-dir='./conta-nao-producao/**' --queue-exclude-dir='./conta-producao/**' --queue-exclude-dir='./conta-redes/**'
```

Analisar saída (outputs) do apply.