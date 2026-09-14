## Trivy

Trivy é uma ferramenta de verificação estática que permite validar a segurança e a conformidade dos recursos do Terraform.

### Exemplos de uso

1. Para analisar um módulo terraform manualmente.
    ```sh
    trivy config .
    ```
1. Restringir a análise ao terraform. O Trivy também permite analisar outros tipos de arquivos, como manifestos do Kubernetes, Dockerfile, etc.
    ```sh
    trivy config --quiet --misconfig-scanners terraform .
    ```
1. Pode também analisar o plano terraform
    ```sh
    terraform init
    terraform plan -out=tfplan
    trivy config --quiet tfplan
    ```
1. Permite filtrar os resultados por severidade.
    ```sh
    trivy config --severity HIGH,CRITICAL --quiet .
    ```
1. Definir Exit code para quando encontrar problemas. Útil para pipelines de CI/CD.
    ```sh
    trivy config --exit-code 1 --severity HIGH,CRITICAL --quiet .
    echo $?
    ```
1. Permite informar um arquivo com valores de variáveis para análise do terraform.
    ```sh
    trivy config --tf-vars dev.auto.tfvars --quiet .
    ```
1. Resolver os problemas encontrados pelo Trivy. Para cada problema, o Trivy sugere uma referência de documentação para a solução que deve ser aplicada no código. Não iremos praticar a solução ao vivo, pois demandaria bastante tempo.
1. Perceba que os apontamentos do Trivy não impedem a execução do fluxo de trabalho do Terraform, mas é uma boa prática corrigir os problemas apontados pelo Trivy para manter o código limpo e aderente às boas práticas.
    ```sh
    terraform plan -out=tfplan
    terraform apply tfplan
    terraform destroy
    ```

- **Desafio**: usar o Trivy para verificar o código deste diretório e corrigir ou adicionar exceção para os problemas de segurança e conformidade encontrados.