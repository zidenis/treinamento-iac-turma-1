# Provisionar Stacks Edge Logging e Edge Setup

Provisionar na conta de testes as stacks iniciais para uso do Iac/JT:

- Stack Edge Logging
- Stack Edge Setup

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

## Inicializar Stack Edge Logging

A documentação completa da Stack Edge Logging para o operador de IAC está em <https://git.pje.csjt.jus.br/cloud/iac/projects/aws-live/-/blob/v1.0.0-beta.4/docs/02-operator-manual/edge/edge-logging.md>

Ao consultar a documentação lembre-se sempre de ajustar para selecionar a tag da versão desejada.

### Preparar arquivo stack.yaml

Ajuste os arquivos `conta-seguranca/edge-logging/stack.yaml` e `conta-nao-producao/edge-logging/stack.yaml`:

- `tags`: ajuste as tags para constar o numero do seu tribunal
- `s3_buckets_suffix`: indique as iniciais do seu nome, apenas para garantir buckets com nomes únicos.

### Executar comandos para instanciar Stack Edge Logging

A partir do diretório `aws-live` e aplique comando `terragrunt plan` para todas as stacks edge-logging, excluindo a `conta-producao` que não está sendo usada no treinamento:

```bash
cd aws-live
terragrunt run --all plan --queue-include-dir='**/edge-logging/' --queue-exclude-dir='./conta-producao/**'
```

É mostrado no comando o plano de ação e a relação de dependência entre as instâncias dos módulos `edge-logging`

```console
17:52:31.887 INFO   The following units will be run, starting with dependencies and then their dependents:
.
╰── conta-seguranca/edge-logging
    ╰── conta-nao-producao/edge-logging
```

Execute o comando para aplicar a stack nas contas devidas:

```bash
terragrunt run --all apply --queue-include-dir='**/edge-logging/' --queue-exclude-dir='./conta-producao/**'
```

## Inicializar Stack Edge Setup

A documentação completa da Stack Edge Setup para o operador de IAC está em <https://git.pje.csjt.jus.br/cloud/iac/projects/aws-live/-/blob/v1.0.0-beta.4/docs/02-operator-manual/edge/edge-setup.md>

Ao consultar a documentação lembre-se sempre de ajustar para selecionar a tag da versão desejada.

### Preparar arquivo stack.yaml

Ajuste o arquivo `conta-nao-producao/edge-setup/stack.yaml`:

- `certificates[0].domain_name`: ajuste para wildcard do domínio criado na tarefa de stack DNS. ex: `*.lbm.ddnsgeek.com`
- `tags`: ajuste as tags para constar o numero do seu tribunal

### Executar comandos para instanciar Stack Setupp

Execute o código iac com terragrunt a partir do diretório `conta-nao-producao/edge-setup/`:

```bash
cd conta-nao-producao/edge-setup/
terragrunt plan
terragrunt apply
cd -
```

Os elementos da Stack Edge Setup serão criados. Todavia, o certificado criado depende de validação de Challenge DNS para ficar utilizável.

Abra o console AWS, busque na region `us-east-1` pelo ACM Certificate. Ele estará no status `pending validation`.

Realize a resolução do Challenge DNS criando a entrada CNAME requerida pelo certificado. O tempo estimado para propagação DNS da entrada CNAME para validação é por volta de 10 minutos.

Após o procedimento, aguarde o tempo de propagação do DNS e o status deve ser atualizado automaticamente para `issued`.
