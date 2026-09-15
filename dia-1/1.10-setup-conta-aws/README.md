## Setup das contas AWS usadas no laboratório

A AWS apoia este treinamento com o fornecimento de contas AWS para realização de laboratórios IaC para nuvem.

### Atividades

1. Acesse o link do workshop que será compartilhado e faça login (OTP) com seu e-mail de inscrição no treinamento
    ```url
    https://catalog.us-east-1.prod.workshops.aws/join?access-code=
    ```
1. Copie as credenciais para o AWS CLI pelo link `Get AWS CLI credentials` e cole no terminal do container.
    ```sh
    export AWS_DEFAULT_REGION="us-east-1" # utilizar sempre a região us-east-1 
    export AWS_ACCESS_KEY_ID="exemplo"
    export AWS_SECRET_ACCESS_KEY="exemplo"
    export AWS_SESSION_TOKEN="exemplo"
    ```
1. Valide o acesso às contas AWS executando o comando `aws sts get-caller-identity`
    ```sh
    unset AWS_ENDPOINT_URL # evitar que o AWS CLI esteja utilizando o emulador local
    aws sts get-caller-identity
    ```
    ```json
    {
    "UserId": "AROATCKAQ52TY6QBTK6L4:Participant",
    "Account": "211125595815",
    "Arn": "arn:aws:sts::211125595815:assumed-role/WSParticipantRole/Participant"
    }
    ```
1. Criar um usuário administrador no IAM da conta de laboratório. Este login será utilizado nas demais práticas.
    ```sh
    export EMAIL="nome@trtXX.jus.br"
    aws iam create-user --user-name "$EMAIL"
    read -sp "Digite a senha do usuario: " IAM_PASSWORD && echo
    aws iam create-login-profile --user-name "$EMAIL" --password "$IAM_PASSWORD" --no-password-reset-required
    aws iam attach-user-policy --user-name "$EMAIL" --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

    ```
1. Efetuar o fluxo de login de navegador para a nova conta AWS criada
    ```sh
    aws login --profile treinamento --remote
    # Abra a URL informada em um navegador e complete o fluxo de autenticação.
    # Estamos utilizando a opção --remote porque estamos executando o fluxo em um container/VM.
    # Em nossa estação de trabalho o processo é mais automatizado. O navegador é aberto automaticamente e o código de autorização não precisa ser informado manualmente.
    # No caso do container/VM, é necessário copiar e colar o `authorization code`.
    ```
    **Importante:** realize o fluxo de login de navegador para a nova conta AWS criada no passo anterior. Fique atento para não reutilizar uma sessão existente para outra conta ou usuário.
1. Entenda a utilização de perfís do AWS CLI
    ```sh
    aws sts get-caller-identity
    aws sts get-caller-identity --profile treinamento
    unset AWS_ACCESS_KEY_ID && unset AWS_SECRET_ACCESS_KEY && unset AWS_SESSION_TOKEN
    export AWS_PROFILE="treinamento"
    aws sts get-caller-identity
    ```
 1. Memorize as credenciais do usuário criado no passo 4. Os arquivos de configurações do AWS CLI (ex.: ~/.aws/config) serão preservados entre as práticas se você executou o container mapeando o volume do diretório `.aws` para o diretório `/home/iac/.aws` do container. Isto é feito para que você não precise repetir o fluxo de login entre execuções do container.
    ```sh
    # Em grande parte, as práticas do treinamento pressupõem que a execução do container seja feita a partir do diretório `treinamento-iac` que fora clonado do repositório do treinamento
    pwd
    # /home/user/treinamento-iac
     git remote -v
    # origin  https://git.pje.csjt.jus.br/cloud/iac/treinamento-iac.git (fetch)
    # origin  https://git.pje.csjt.jus.br/cloud/iac/treinamento-iac.git (push)
    sudo docker run --privileged --rm -it -v "$(pwd):/treinamento" \
      -v ".aws:/home/iac/.aws" zidenis/treinamento-iac-nuvem-jt:2.2.0
    # Sempre que iniciar o container, defina a variável de ambiente AWS_PROFILE e verifique se o AWS CLI está utilizando o perfil correto.
    export AWS_PROFILE="treinamento"
    aws sts get-caller-identity
    ```
1. Opcionalmente, você pode efetuar o logout do AWS CLI para a conta de laboratório. Para ambientes de trabalho real, efetuar sempre o logout é a prática recomendada.
    ```sh
     aws logout --profile treinamento
    ```