## checkov

Checkov é uma ferramenta de verificação estática que permite validar a segurança e a conformidade dos recursos do Terraform.

### Exemplos de uso

1. Analise o código no diretório atual:
    ```sh
    checkov -d .
    ```
1. Apresenta o resultado da análise do código terraform em outros modos:
    ```sh
    checkov -d . --framework terraform --quiet
    checkov -d . --framework terraform --quiet --compact
    ```
1. É possível também analisar um terraform plan gerado previamente:
    ```sh
    terraform init
    terraform plan -out=tfplan
    terraform show -json tfplan | jq '.' > tfplan.json
    checkov -f tfplan.json --quiet
    ```
1. Resolver os problemas encontrados pelo Checkov. Para cada problema, o Checkov sugere uma referência de documentação para a solução que deve ser aplicada no código. Não iremos praticar a solução ao vivo, pois demandaria bastante tempo.
1. Perceba que os apontamentos do Checkov não impedem a execução do fluxo de trabalho do Terraform, mas é uma boa prática corrigir os problemas apontados pelo Checkov para manter o código limpo e aderente às boas práticas.
    ```sh
    terraform apply "tfplan"
    terraform destroy
    ```

- **Desafio**: usar o checkov para verificar o código deste diretório e corrigir ou adicionar exceção para os problemas de segurança e conformidade encontrados.