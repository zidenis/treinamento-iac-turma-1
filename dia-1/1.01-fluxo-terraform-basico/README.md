## Fluxo Básico de Trabalho com Terraform

Exemplo mínimo do fluxo básico de provisionamento de infraestrutura na AWS com Terraform.
O código criará um Bucket S3 chamado `capacitacao-iac-terraform-1-fluxo-basico`.
Utilizaremos o emulador de serviços AWS chamado `floci` para provisionar a infraestrutura localmente, sem necessidade de uma conta AWS real.
O bucket criado será publicamente acessível por URL com um website indicando a data e hora em que o bucket foi criado.

### Preparação do ambiente de execução

```sh
floci status
eval $(floci env)
# Para que o terraform se conecte ao emulador, precisamos definir um endpoint local.
cat providers.tf
```

Se o emulador não estiver disponível, é provável que o container do floci ainda esteja sendo carregado. Verifique com `docker ps` e `cat /tmp/floci.log` e aguarde o término do carregamento do container.

### Fluxo de trabalho

1. Códificação. Veja o conteúdo do arquivo `main.tf` para entender o que já foi codificado: 
    ```sh
    grep "^#" main.tf
    ```
1. Inicialização (init) do Terraform: 
    ```sh
    terraform init
    ```
1. Planejamento: 
    ```sh
    terraform plan
    ```
1. Aplicação:
    ```sh
    terraform apply
    ```

### Testes
```sh
curl "$(terraform output -raw website_URL)" -w "\n"
```
- URL para uma conta AWS real:
  - `http://capacitacao-iac-terraform-1-fluxo-basico.s3-website-sa-east-1.amazonaws.com/` 
  - Teste em seu navegador. Funciona porque esta IaC foi executada anteriormente em uma conta AWS real.
- Teste repetir o fluxo plan/apply para atualizar a infraestrutura.
- Observe que, propositalmente, o código utiliza a função `timestamp()` no `index.html`, portanto, a cada execução do fluxo, o plano de execução sempre indicará uma mudança.

### Limpeza
```sh
terraform destroy
```