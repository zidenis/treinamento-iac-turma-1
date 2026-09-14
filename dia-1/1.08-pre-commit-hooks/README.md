## Pre-commit hooks

Pre-commit hooks são scripts executados antes de um commit ser realizado.
Eles podem ser usados para automatizar tarefas, como validação de código, formatação, execução de testes, entre outros.

### Exemplos de uso

1. Configure o arquivo `.pre-commit-config.yaml` na raiz do seu repositório com os hooks desejados. Veja `.pre-commit-config.yaml` como exemplo. Inicializaremos o diretório como um repositório git para utilizar este repositório git como exemplo.
    ```sh
    cat .pre-commit-config.yaml
    git init -b main
    git config user.name "iac" && git config user.email "nuvem-jt"
    git add .
    git commit -m "Initial commit"
    ```
1. Inicializando e validando arquivos terraform
    ```sh
    terraform init
    ```
1. Executar os hooks do pre-commit manualmente.
    ```sh
    pre-commit run --all-files
    ```
1. Instale os scripts de git hooks no repositório.
    ```sh
    pre-commit install
    ```
1. Simule a criação de uma variável do módulo terraform e tente fazer o commit da modificação.
```sh
cat >> variables.tf <<EOL

variable "VARIAVEL_exemplo" {
  type = string
}

EOL
git add variables.tf
git commit -m "Adicionando variável de exemplo"
```
1. O commit será rejeitado. 

- **Desafio**: Corrija o nome da variável, adicione a sua descrição e faça um uso (uma referência) dela no arquivo `main.tf`. Em seguida, tente fazer o commit novamente.
```sh
git add variables.tf
git commit -m "Adicionando variável de exemplo"
```
