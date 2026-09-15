## Uso de Template para Criação de Módulos Filhos (_child modules_)

Módulo filho é um módulo Terraform chamado por outro módulo para encapsular e reutilizar um conjunto de recursos e configurações. Um módulo filho pode, por sua vez, utilizar outros módulos.

Para facilitar a criação de módulos filhos, utilizaremos o template `terraform-aws-child-module-template` que serve como ponto de partida para criar um novo módulo filho adotando padrões da Nuvem-JT.

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
cd dia-2/2.01-child-module/
```

### Atividades

1. **Escolha**: um nome para seu módulo e clone o repositório git com o código do template de módulo filho:
   ```sh
   export CHILD_MODULE="meu-modulo"
   # git clone https://git.pje.csjt.jus.br/cloud/iac/templates/ terraform-aws-child-module-template.git
   git clone https://[PAT]@github.com/zidenis/terraform-aws-child-module-template $CHILD_MODULE
   tree -a -L 1 -A $CHILD_MODULE
   cd $CHILD_MODULE
   mdcat README.md
   ```
   Perceba:
   1. O template possui um conjunto de arquivos e diretórios para uma configuração básica de módulos Terraform, em conformidade com o padrão de boas práticas de IaC da Nuvem-JT.
   1. **Porém**, o repositório clonado ainda não está pronto para o desenvolvimento do novo módulo. É preciso configurar (Bootstrap) o repositório.

1. **Bootstrap**: O template utiliza o utilitário `make` para automatizar a configuração do repositório.
   ```sh
   make help
   make init
   # Informe o seu tribunal em caracteres minúsculos (conformidade com o padrão de tags). Esse vamor será utilizado na personalização do módulo.
   git log
   mdcat README.md
   terraform init
   ```
   Perceba:
   1. Verifica se as ferramentas recomendadas estão instaladdas no ambiente.
   1. Inicializa um novo repositório git para o módulo.
1. **Desenvolvimento**: simule o desenvolvimento de uma configuração Terraform
   ```sh
   cp terraform.tfvars.example terraform.tfvars
   terraform plan
   
   # Alguns erros devem ser apresentados pois as variáveis de entrada precisam ser personalizadas
   sed -i "s/undefined-module-name/$CHILD_MODULE/" terraform.tfvars
   sed -i "s/undefined-module-scope/nacional/" terraform.tfvars
   sed -i "s/undefined-module-cost-group/infra/" terraform.tfvars
   sed -i "s/undefined-module-environment/dev/" terraform.tfvars
   sed -i "s/undefined-module-organization/trtXX/" terraform.tfvars
   terraform plan
   # Se o plano falhar novamente é porque faltou você alterar o XX para a tag jt:organization

   terrafomr apply
   # O recurso "terraform_data" serve para armazenar algum dado de qualquer tipo. Neste exemplo simples, estamos apenas armazenando o valor da variável jt:application-name

   # simulando o desenvolvimento de um recurso na AWS
   cp ../provider.tf.example ./provider.tf
   cat provider
   cp ../main.tf.example ./main.tf
   cat main.tf
   terraform plan -out="tfplan"
   terraform apply "tfplan"
   aws iam get-user --user-name treinamento-iac-child-module-user
   ```
   Perceba:
   1. Estamos simulando a criação de um IAM User na AWS
   1. As tags definidas em terraform.tfvars são aplicadas ao usuário pois no provider "aws" as tags validadas são aplicadas como default_tags.

1. **Versionamento**:
   ```sh
   git status
   git add .
   git commit -m "Cria um AWS IAM User"

   # Os pre-commit hooks são executados 
   # Uma regra do Checkov impede que o commit seja realizado.

   # Adicione em main.tf uma exceção para a regra do Checkov 
   sed -i '3i\  #checkov:skip=CKV_AWS_273:treinamento' main.tf
   git add .
   git commit -m "Cria um AWS IAM User"
   ```
   Perceba: 
   1. Modificamos apenas o `main.tf`. `provider.tf` não é versionado (está no .gitignore), pois estamos desenvolvendo um módulo filho.
   1. Perceba que o scanner de segurança `Checkov` impediu que o commit fosse realizado. Mas o outro scanner de segurança `Trivy` não identificou nenhum problema.
   1. Para nosso ambiente de laboratório, ignoramos o alerta do Checkov por meio de uma exceção.