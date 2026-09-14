## Terraform-docs

Terraform-docs é uma ferramenta que gera documentação para módulos Terraform. Ele analisa os arquivos `.tf` e cria uma documentação legível em Markdown, HTML ou outros formatos.

### Exemplos de uso

1. Gerar documentação em Markdown para um módulo Terraform:
    ```sh
    terraform-docs markdown table .
    ```
1. Injetar a documentação gerada no `README.md`. 
    ```sh
    terraform-docs markdown table \
      --output-file README.md \
      --output-mode inject .
1.1 A documentação gerada será injetada neste `README.md` entre os marcadores `BEGIN_TF_DOCS` e `END_TF_DOCS` (ver abaixo). Se esses marcadores não existirem, a documentação é adicionada no final do arquivo.

<!-- BEGIN_TF_DOCS -->
... documentação gerada ...
<!-- END_TF_DOCS -->

A Documentação do módulo gerada pelo `terraform-docs` será adicionada acima.