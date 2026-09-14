# Treinamento de IaC/JT - Turma 1 (Setembro/26)

Pré-requisitos:

- Conhecimentos básicos de Linux, git e computação em nuvem (AWS)
- Autenticar no GitLab do CSJT e configurar um Personal Access Token (PAT)
  - How-to: https://docs.gitlab.com/user/profile/personal_access_tokens/#create-a-personal-access-token
- Conectividade com o GitLab do CSJT
- Docker no host local para execução das atividades do treinamento em ambiente isolado e padronizado
- Contas AWS de laboratórios (serão provisionadas no primeiro dia)

## Dia 1

> Preparar o ambiente de treinamento e iniciar o container padronizado:
```sh
# Baixa o material do treinamento para o ambiente local, utilizando as credenciais (PAT) de acesso ao GitLab.
git clone https://[pat_name]:[glpat_value]@git.pje.csjt.jus.br/cloud/iac/treinamento-iac.git
cd treinamento-iac/
# Iniciar o container Docker padronizado do treinamento
sudo docker run --privileged --rm -it -v "$(pwd):/treinamento" zidenis/treinamento-iac-nuvem-jt:2.1.0
```

### Atividades

- [ ] Fluxo básico Terraform (1.01-fluxo-basico)
- [ ] Entendendo HCL (1.02-hcl)
- [ ] Gerenciamento de Versões Terraform (1.03-tenv)
- [ ] Qualidade de Código (1.04-tflint)
- [ ] Validação de Segurança (1.05-checkov)
- [ ] Validação de Segurança (1.06-trivy)
- [ ] Documentação de Módulos (1.07-terraform-docs)
- [ ] Automação de Ambiente de Desenvolvimento Local (1.08-pre-commit-hooks)
- [ ] Utilização da IDE VScode com Dev Container (1.09-vscode-devcontainer)
- [ ] Configurar acesso às contas AWS (1.10-setup-conta-aws)
- [ ] Provisionar uma instância EC2 com IP público (1.11-ec2-ip-publico)

## Dia 2

## Dia 3

## Dia 4

