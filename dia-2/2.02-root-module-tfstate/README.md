## Módulo Raiz com Backend Remoto para Terraform State

Nesta prática veremos questões relacionadas ao armazenamento do Terraform State em um backend remoto (Bucket S3), com state locking e versionamento.

Módulo raiz (Root) é um módulo a partir do qual o Terraform é executado para provisionar a infraestrutura. É responsável por instanciar recursos diretamente ou utilizar outros módulos (filhos), fornecendo os valores de entrada necessários para sua configuração.

Para facilitar a criação do módulo raiz, utilizaremos o template `terraform-aws-root-module-template` que serve como ponto de partida para criar um novo módulo raiz adotando padrões da Nuvem-JT.

### Pré-requisito
**Container docker atualizado para versão 2.2.0** 
1. Executar o container do ambiente de laboratório a partir da raiz do repositório git.
   ```sh
   sudo docker run --privileged --rm -it \
        -v "$(pwd):/treinamento" -v ".aws:/home/iac/.aws" \
        zidenis/treinamento-iac-nuvem-jt:2.2.0
   ls
   # README.md  dia-1  dia-2  dia-3  dia-4
   ```
1. Ter executado a atividade de setup da conta de laboratório [dia-1/1.10-setup-conta-aws](../../dia-1/1.10-setup-conta-aws).
   ```sh
   # O profile "treinamento" deve estar configurado. Ex:
   cat ~/.aws/config 
   ## [profile treinamento]
   ## login_session = arn:aws:iam::123456789012:user/nome.sobrenome@trtxx.jus.br
   export AWS_PROFILE="treinamento"
   export AWS_REGION="us-east-1"
   aws sts get-caller-identity
   # Efetue o "aws login --remote" se a resposta não for semelhante abaixo. 
   # {
   #    "UserId": "AIDA3FLDYHCY7IL6TMF32",
   #    "Account": "123456789012",
   #    "Arn": "arn:aws:iam::123456789012:user/nome.sobrenome@trtxx.jus.br"
   # }
   ```


### Ambiente
```sh
# Garanta que esteja utilizando a região us-ease-1
export AWS_REGION="us-east-1"
# Validando acesso AWS. Em caso de erro, veja os "pré-requisitos"
aws sts get-caller-identity
# exteja no diretório da pratica
cd dia-2/2.02-root-module-tfstate/
```

### Atividades

1. **Escolha**: um nome para seu módulo e clone o repositório git com o código do template de módulo raiz:
   ```sh
   # Defina um nome próprio para o seu módulo. 
   # Use suas iniciais como sufixo para evitar colisão de nomes no bucket S3 que será criado.
   export ROOT_MODULE="meu-modulo-raiz-[iniciais]" 
   # git clone https://git.pje.csjt.jus.br/cloud/iac/templates/ terraform-aws-root-module-template.git
   git clone https://PAT@github.com/zidenis/terraform-aws-root-module-template.git $ROOT_MODULE
   tree -a -L 1 -A $ROOT_MODULE
   cd $ROOT_MODULE
   mdcat README.md
   ```
   Perceba:
   1. O template de módulo raiz apresenta uma organização de arquivos e diretórios diferente do template de módulos filhos utilizado na atividade anterior.
   1. O diretório `environments` será utilizado para agrupar os ambientes que serão provisionados pelo módulo.
   1. `environments/.env` serve de modelo de configuração terraform para cada ambiente
   1. Este template utiliza dois sub-módulos locais: `tag-compliance` e `tfstate-s3-bucket` 
   1. O repositório clonado ainda não está pronto para o desenvolvimento do novo módulo. É preciso configurar (Bootstrap) o repositório.

1. **Bootstrap de um ambiente**: O template utiliza o utilitário `make` para automatizar a configuração do repositório.
   ```sh
   make help

   make init
   # Informe o seu tribunal em caracteres minúsculos (conformidade com o padrão de tags). Esse vamor será utilizado na personalização do módulo.
   git log
   mdcat README.md
   sed -i 's/sa-east-1/us-east-1/g' environments/.env/terraform.tfvars.example # Conta de laboratório restringe o uso da região sa-east-1
   export TF_ENV=dev # defina um nome para o ambiente
   
   make env
   mdcat environments/$TF_ENV/README.md
   
   make bootstrap
   # O bootstrap do Bucket S3 para armazenar o tfstate falhará porque as tags não foram personalziadas conforme preconiza o padrão da Nuvem-JT.
   sed -i 's/undefined-application-scope/nacional/g' environments/$TF_ENV/terraform.tfvars
   sed -i 's/undefined-automation-tool/terraform/g' environments/$TF_ENV/terraform.tfvars
   sed -i 's/undefined-automation-version/0.0.1/g' environments/$TF_ENV/terraform.tfvars
   sed -i 's/undefined-cost-group/infra/g' environments/$TF_ENV/terraform.tfvars
   
   make bootstrap
   cat environments/$TF_ENV/backend.tf

   aws s3 ls s3://$(terraform -chdir=environments/$TF_ENV output -raw tfstate_bucket_name)
   terraform -chdir=environments/$TF_ENV state list
   ```
   Perceba:
   1. `make init` inicializou um novo repositório git para este módulo raiz
   1. `make env` criou o diretório `./environments/dev/` foi configurado para armazenar a configuração de infraestrutura do novo ambiente
   1. `make boostrap` criou e configurou um bucket para armezanamento remoto dos estados terraform
   1. Após a criação e configuração do bucket, o estado terraform foi reinicializado, de forma que o bucket existe na infraesutrutra real, mas não é mais gerenciado pelo Terraform. Isso é feito para evitar que um destroy da configuração acabe por apagar as configurações do próprio bucket de estados

1. **Bootstrap de novos ambientes**
   ```sh
   # Editando o prórpio modelo de ambiente (.env) para conformidade de tags
   sed -i 's/undefined-application-scope/nacional/g' environments/.env/terraform.tfvars.example
   sed -i 's/undefined-automation-tool/terraform/g' environments/.env/terraform.tfvars.example
   sed -i 's/undefined-automation-version/0.0.1/g' environments/.env/terraform.tfvars.example
   sed -i 's/undefined-cost-group/infra/g' environments/.env/terraform.tfvars.example
   
   # Ambiente de Homologação
   TF_ENV=hml make env 
   TF_ENV=hml make bootstrap
   
   # Ambiente de Produção em um comando
   TF_ENV=prd make env bootstrap
   
   aws s3 ls
   ```
   Perceba:
   1. As alterações realizadas no modelo de ambientes (.env) são utilizadas para os novos ambientes
   1. O tamplate facilia a criação de novos ambientes para o módulo raiz, acelerando o desenvolvimento e mantendo o padrão estabelecido
   1. Cada ambiente possui seu próprio bucket para armazenar o tfstate de forma isolada