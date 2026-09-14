## Componentes e estruturas da HCL

1. Blocos (Variáveis, Recursos, locals, data, module, output, provider, terraform)
1. Argumentos
1. Valores e expressões
1. Identificadores
1. Referências
1. Comentários

### Atividades

1. Inspecione o arquivo `hcl.tf` com exemplos de uso dos principais componentes da HCL.
1. Inicialização do Terraform. Perceba que estamos baixando um módulo do Terraform Registry. O módulo `terraform-aws-modules/s3-bucket/aws` versão 5.15.4 será baixado. Esta versão que impõe um novo requisito de versão do provider `hashicorp/aws`(>= 6.42.0). Perceba também que uma reexecução do comando `terraform init` não baixará novamente o módulo, pois ele já foi baixado e está em cache.
   ```sh
   grep required_providers hcl.tf -A 4
   grep modules/s3-bucket hcl.tf -A 1
   terraform init
   # - Finding hashicorp/aws versions matching ">= 6.0.0, >= 6.42.0"
   terraform init
   ```
1. Aplicação da infraestrutura. Você percebe na saída do comando `terraform apply` a definição de tags em dois dos recursos criados? sabe explicar por quê as tags são diferentes? qual a diferença de `tags` e `tags_all`? veremos essas explicações mais a frente (dia 2 do treinamento).
   ```sh
   terraform apply
   ```
1. Verifique os buckets criados no S3
   ```sh
   aws s3 ls
   ```
1. Execute novamente passando a variável `environment=prod` e observe as mudanças. Por que um recurso será criado e outro destruído?
   ```sh
   terraform apply -var "environment=prod"
   aws s3 ls
   ```