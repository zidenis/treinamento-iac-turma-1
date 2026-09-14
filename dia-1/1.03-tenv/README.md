## tenv

tenv é um gerenciador de versões do Terraform e Terragrunt, permitindo instalar e alternar entre diferentes versões dessas ferramentas de forma dinâmica.

### Exemplos de uso 

1. Instalar a versão mais recente do Terraform
    ```sh
    tenv tf install latest
    ```
1. Instalar uma versão específica do Terraform
    ```sh
    tenv tf install 1.14.9
    ```
1. Definir a versão global a ser usada para o Terraform
    ```sh
    terraform --version
    tenv tf use 1.14.9
    terraform --version
    ```
1. Listar as versões instaladas
    ```sh
    tenv tf list
    ```
1. Troca automática de versão do Terraform em diretórios com arquivo `.terraform-version`
    ```sh
    terraform --version
    echo "~>1.14.0" > .terraform-version
    terraform --version
    tenv tf detect
    rm .terraform-version
    terraform --version
    ```
1. Remover uma versão que não precisa mais
    ```sh
    tenv tf uninstall 1.14.9
    tenv tf list
    ```
1. Instalação automática do CLI
    ```sh
    export TENV_AUTO_INSTALL=true
    echo "~>1.14.0" > .terraform-version
    terraform --version
    ```