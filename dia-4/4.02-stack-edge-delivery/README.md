# Provisionar Stack Edge Delivery e Criar Registro DNS

Provisionar na conta do treinamento a Stack Edge Delivery e criar a respectiva entrada DNS.

Para todas as etapas desta atividade usaremos a instância EC2 criada na [Atividade de Criação de Instância EC2 com IP Público](../../dia-1/1.11-ec2-ip-publico/README.md). Esta Instância já possui todas as ferramentas instaladas par uso do Iac/JT

## Conectar SSH a instancia EC2

Conecte via SSH à instância criada na atividade anterior:

```bash
cd ../../dia-1/AT_ec2_ip_publico/terraform

# Executar terraform apply para atualizar informação de IP publico
terraform apply

ssh -i iac-ssh-private-key.pem ubuntu@$(terraform output -raw instance_ip)
```

Após conexão todos as etapas seguintes serão executados como root. Para abrir uma sessão como root:

```bash
sudo -i
```

## Alternativa: Rodar comandos via container

Alternativamente, é possível executar os comandos deste lab via container:

```bash
# Iniciando container a partir de Linux com Docker
sudo docker run --privileged --rm -it \
-v "$(pwd):/treinamento" -v "$(pwd)/.aws:/home/iac/.aws"\
zidenis/treinamento-iac-nuvem-jt:2.2.0

# Iniciando container a partir de Windows com Podman
# podman run --privileged --rm -it -v "$(pwd -W):/treinamento" -v "$(pwd -W)/.aws:/home/iac/.aws" zidenis/treinamento-iac-nuvem-jt:2.2.0
```

Passos abaixo a partir do container:

```bash
tenv tf install 1.15.9
tenv tf use 1.15.9
tenv tg install 1.1.3
tenv tg use 1.1.3
export TG_PROVIDER_CACHE=1
export TG_PROVIDER_CACHE_DIR=/treinamento/.terragrunt-cache/terragrunt/providers
```

## Inicializar Stack Edge Delivery

A documentação completa da Stack Edge Delivery para o operador de IAC está em <https://git.pje.csjt.jus.br/cloud/iac/projects/aws-live/-/blob/v1.0.0-beta.4/docs/02-operator-manual/edge/edge-delivery.md>

Ao consultar a documentação lembre-se sempre de ajustar para selecionar a tag da versão desejada.

### Preparar arquivo instance.yaml

Ajuste o arquivo `conta-nao-producao/edge-delivery/exemplo/instance.yaml`:

- `domain_names`: Substitua o exemplo por `pje.` **acrescendo domínio criado na atividade da Stack DNS**. Ex: `["pje.lbm.ddnsgeek.com"]`
- `origin.dns_name`: Indique o `alb_dns_name` obtido na atividade de Criação do ALB
- `certificate_domain`: Indique o `domain_name` vinculado ao certificado usado na atividade da Stack Edge Setup. Ex:  `"*.lbm.ddnsgeek.com"`
- `tags`: ajuste as tags para constar o numero do seu tribunal

### Executar comandos para instanciar Stack Edge Delivery

Entre no diretório `conta-nao-producao/edge-delivery/exemplo` e execute os comandos terragrunt para instanciar a stack:

```bash
pwd # Garanta que esteja no diretorio aws-live

cd conta-nao-producao/edge-delivery/exemplo
terragrunt plan
terragrunt apply
```

Pode levar alguns minutos para criar a CloudFront Distribution. Ao final do comando são mostradas as outputs

```console
01:41:33.159 STDOUT terraform: Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
01:41:33.159 STDOUT terraform:
01:41:33.159 STDOUT terraform: Outputs:
01:41:33.159 STDOUT terraform:
01:41:33.161 STDOUT terraform: cf_distribution_aliases = toset([
01:41:33.161 STDOUT terraform:   "pje.lbm.ddnsgeek.com",
01:41:33.161 STDOUT terraform: ])
01:41:33.161 STDOUT terraform: cf_distribution_arn = "arn:aws:cloudfront::999999999999:distribution/ABC123ABC123AB"
01:41:33.161 STDOUT terraform: cf_distribution_domain_name = "abc123456789ab.cloudfront.net"
01:41:33.161 STDOUT terraform: cf_distribution_id = "ABC123ABC123AB"
01:41:33.161 STDOUT terraform: hosted_zone_id = "Z123ABC123ABC1"
01:41:33.161 STDOUT terraform: waf_arn = "arn:aws:wafv2:us-east-1:999999999999:global/webacl/jt-webacl-dev-exemplo/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
01:41:33.161 STDOUT terraform: waf_capacity = 711
01:41:33.162 STDOUT terraform: waf_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
01:41:33.162 STDOUT terraform: waf_logging_configuration_arn = "arn:aws:wafv2:us-east-1:999999999999:global/webacl/jt-webacl-dev-exemplo/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
01:41:33.162 STDOUT terraform: waf_name = "jt-webacl-dev-exemplo"
01:41:33.162 STDOUT terraform: waf_scope = "CLOUDFRONT"
```

### Criar Entrada DNS

Entre no console de administração do domínio criado e crie uma entrada CNAME para que o `domain_name` indicado na Stack Edge Delivery aponte para o valor da output `cf_distribution_domain_name`.

### Validar execução da atividade

- Abra o browser e realize acesso ao domínio configurado. Ex: `pje.lbm.ddnsgeek.com`
- No terminal, deixe executando um loop de curl para fazer requisições:

```bash
while true; do
    curl -sIL "https://pje.lbm.ddnsgeek.com/"
    sleep 1
done
```

- Aguarde 2 minutos e verifique os logs de WAF e CloudFront no console via AWS Athena

No console:
Athena --> Menu --> Query Editor

#### Exemplos de Consultas no Athena

Logs do WAF:

```sql
SELECT
  httprequest.clientip AS client_ip,
  httprequest.country AS country,
  from_unixtime(timestamp / 1000.0) AS request_datetime,
  *
FROM jt_gluedb_dev_waf_logs.jt_gluetbl_dev_waf_requests
WHERE webacl_name = 'jt-webacl-dev-exemplo'
  AND year = cast(year(current_date) AS varchar)
  AND month = lpad(cast(month(current_date) AS varchar), 2, '0')
LIMIT 50
```

Logs do Cloudfront:

```sql
SELECT
  *
FROM jt_gluedb_dev_cf_access_logs.jt_gluetbl_dev_cloudfront_logs
WHERE dist_name = 'jt-cdn-dev-exemplo'
  AND year = year(current_date)
  AND month = month(current_date)
LIMIT 50
```
