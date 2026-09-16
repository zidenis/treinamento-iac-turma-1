# Criar Domínio na Internet e Provisionar Stack DNS

Criar Domínio na Internet e Provisionar na conta de testes a Stack DNS

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

## Criar Domínio na Internet

Para fins de treinamento iremos criar um domínio gratuito no <dynu.com>. Seguem etapas:

- Realize seu cadastro em <dynu.com>
- No `Control Panel` clique em  `DDNS Services`
- Na `Option Use Our Domain Name` preencha o host e escolha um top level domain. Ex: host `lbm`, top level `ddnsgeek.com`. Clique em `Add`
- Na tela seguinte adicione o IP da sua instância ec2 com IP público e valide com netcat ou telnet o acesso à porta 22.

```bash
nc -z -v lbm.ddnsgeek.com 22
```

## Realizar AWS Login via Maquina Remota

Para fazer login a partir de máquina remota basta adicionar a flag `--remote` ao comando.

```bash
aws login --profile treinamento --remote    # importante region deve ser sa-east-1
```

Prossiga com as orientações do prompt para concluir login.

Configuração do profile e validação:

```bash
export AWS_PROFILE="treinamento"

aws sts get-caller-identity
# Exemplo de resulltado esperado:
# {
#     "UserId": "AIDA4ZAXWAWAZACYXNXJC",
#     "UserId": "XXXXXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/nome.sobrenome@trtxx.jus.br"
# }
```

## Inicializar Stack DNS

A documentação completa da Stack DNS para o operador de IAC está em <https://git.pje.csjt.jus.br/cloud/iac/projects/aws-live/-/blob/v1.0.0-beta.4/docs/02-operator-manual/dns.md>

Ao consultar a documentação lembre-se sempre de ajustar para selecionar a tag da versão desejada.

### Preparar arquivo stack.yaml

Ajuste o arquivo `conta-redes/dns/stack.yaml`:

- Remova o item da lista referente à zona reversa
- `domain_name`: Altere o domain name `trtXX.jus.br` para constar o domínio criado no [passo anterior](#criar-domínio-na-internet)
- `tags`: ajuste as tags para constar o numero do seu tribunal

### Executar comandos para instanciar Stack DNS

Entre no diretório `conta-redes/dns` e aplique `terragrunt plan`:

```bash
cd conta-redes/dns
terragrunt plan
```

Em virtude de estarmos usando um domínio não pertencente à JT, é esperado que retorne o seguinte erro:

```console
* Failed to execute "terraform plan" in ./.terragrunt-cache/hBAo9rkf1rOwLHAuV45aNys3N3Q/b_vmxOH0rQobnTqEx0xmah3Puqc/stacks/dns
  ╷
  │ Error: Invalid value for variable
  │
  │   on main.tf line 28, in module "zone":
  │   28:   domain_name          = each.value.domain_name
  │     ├────────────────
  │     │ var.domain_name is "lbm.ddnsgeek.com"
  │
  │ O domain_name deve terminar em .jus.br (ex: trt5.jus.br) ou .in-addr.arpa
  │ (zona reversa).
  │
  │ This was checked by the validation rule at
  │ ../../route53-zone-public/variables.tf:4,3-13.
  ╵

  exit status 1
```

Para efeitos do treinamento não iremos prosseguir no uso dessa stack visto que usaremos domínio externo à JT. Elementos relacionados ao DNS externo serão resolvidos no painel da plataforma externa (dynu.com)

```bash
cd -  # voltando para diretorio aws-live
```

Para ambiente de produção, siga a documentação do operador: <https://git.pje.csjt.jus.br/cloud/iac/projects/aws-live/-/blob/v1.0.0-beta.4/docs/02-operator-manual/dns.md>
