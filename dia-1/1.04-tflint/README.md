## TFlint

Exemplo de configuração do TFlint para validar o código Terraform.

### Exemplos de uso

1. Criar o arquivo de configuração `.tflint.hcl` com plugins e regras. Veja exemplo no arquivo `.tflint.hcl` deste diretório.
    ```sh
    cat .tflint.hcl
    ```
1. Inicializar os plugins do TFlint.
    ```sh
    tflint --init
    ```
1. Validar o código Terraform. Propositalmente, vários `Warnings` foram deixados no código para que o TFlint possa apontar os problemas.
    ```sh
    tflint
    ```
1. Resolver os problemas encontrados pelo TFLint. Para cada problema, o TFLint sugere uma referência de documentação para a solução que deve ser aplicada no código. Não iremos praticar a solução ao vivo, pois demandaria bastante tempo.
1. Perceba que os apontamentos do TFlint não impedem a execução do fluxo de trabalho do Terraform, mas é uma boa prática corrigir os problemas apontados pelo TFLint para manter o código limpo e aderente às boas práticas.
    ```sh
    terraform init
    terraform apply
    terraform destroy
    ```

- **Desafio**: usar o TFLint e corrigir os problemas no código. A solução será compartilhada no Dia 2.