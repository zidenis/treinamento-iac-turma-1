FROM ubuntu:26.04

ARG USERNAME=iac
ARG USER_UID=1000
ARG USER_GID=1000
ENV HOME=/home/iac

# Sistema operacional e pré-requisitos
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        gosu \
        jq \
        less \
        pipx \
        python3 \
        tmux \
        unzip \
        util-linux \
        vim \
        docker.io \
        openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/bin/containerd-stress

# Usuario IaC
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupdel ubuntu 2>/dev/null || true

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd \
        --uid "${USER_UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --shell /bin/bash \
        "${USERNAME}" \
    && usermod -aG docker "${USERNAME}" \
    && mkdir -p \
        /home/${USERNAME}/.tenv \
        /home/${USERNAME}/.local/bin \
        /home/${USERNAME}/awscli \
        /treinamento \
    && chown -R \
        "${USERNAME}:${USERNAME}" \
        /home/${USERNAME} \
        /treinamento

# Instalação das ferramentas
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# tenv
RUN set -eux \
    && TENV_LATEST="$(curl -fsSL https://api.github.com/repos/tofuutils/tenv/releases/latest \
        | jq -r '.assets[] | select(.name | endswith("Linux_x86_64.tar.gz")) | .browser_download_url')" \
    && curl -fsSL -o /tmp/tenv.tar.gz "${TENV_LATEST}" \
    && tar --no-same-owner \
        -xzf /tmp/tenv.tar.gz \
        -C "${HOME}/.tenv" \
    && rm -f /tmp/tenv.tar.gz

# terraform-docs
RUN set -eux \
    && TDOC_LATEST="$(curl -fsSL https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest \
        | jq -r '.assets[] | select(.name | endswith("linux-amd64.tar.gz")) | .browser_download_url')" \
    && curl -fsSL -o /tmp/terraform-docs.tar.gz "${TDOC_LATEST}" \
    && tar --no-same-owner \
        -xzf /tmp/terraform-docs.tar.gz \
        -C "${HOME}/.tenv" \
        terraform-docs \
    && rm -f /tmp/terraform-docs.tar.gz

# TFLint
RUN set -eux \
    && TFLINT_LATEST="$(curl -fsSL https://api.github.com/repos/terraform-linters/tflint/releases/latest \
        | jq -r '.assets[] | select(.name | endswith("tflint_linux_amd64.zip")) | .browser_download_url')" \
    && curl -fsSL -o /tmp/tflint.zip "${TFLINT_LATEST}" \
    && unzip -o /tmp/tflint.zip -d "${HOME}/.tenv" \
    && rm -f /tmp/tflint.zip

# Trivy
RUN set -eux \
    && TRIVY_LATEST="$(curl -fsSL https://api.github.com/repos/aquasecurity/trivy/releases/latest \
        | jq -r '.assets[] | select(.name | endswith("Linux-64bit.tar.gz")) | .browser_download_url')" \
    && curl -fsSL -o /tmp/trivy.tar.gz "${TRIVY_LATEST}" \
    && tar --no-same-owner \
        -xzf /tmp/trivy.tar.gz \
        -C "${HOME}/.tenv" \
        trivy \
    && rm -f /tmp/trivy.tar.gz

# mdcat
RUN set -eux \
    && MDCAT_LATEST="$(curl -fsSL https://api.github.com/repos/BIRSAx2/mdcat/releases/latest \
        | jq -r '.assets[] | select(.name | endswith("linux-gnu.tar.gz")) | .browser_download_url')" \
    && curl -fsSL -o /tmp/mdcat.tar.gz "${MDCAT_LATEST}" \
    && tar --no-same-owner \
        -xzf /tmp/mdcat.tar.gz \
        -C "${HOME}/.local/bin" \
        --wildcards "*/mdcat" \
        --strip-components=1 \
    && rm -f /tmp/mdcat.tar.gz

# Checkov e pre-commit
RUN PIP_NO_CACHE_DIR=1 pipx install checkov \
    && PIP_NO_CACHE_DIR=1 pipx install pre-commit \
    && pipx ensurepath \
    && rm -rf "${HOME}/.cache"

# AWS CLI
RUN curl -fsSL \
        "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
        --install-dir "${HOME}/awscli" \
        --bin-dir "${HOME}/awscli/bin" \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

# Floci
RUN curl -fsSL \
        -o "${HOME}/.local/bin/floci" \
        "https://github.com/floci-io/floci-cli/releases/download/0.2.1/floci-linux-amd64" \
    && chmod +x "${HOME}/.local/bin/floci"

# Bash completions
ENV PATH=/home/iac/.tenv:${PATH}
RUN tenv completion bash \
        > "${HOME}/.tenv/tenv_completion.bash" \
    && terraform-docs completion bash \
        > "${HOME}/.tenv/terraform-docs_completion.bash" \
    && echo 'complete -C "/home/iac/awscli/bin/aws_completer" aws' \
        >> "${HOME}/.bashrc" \
    && echo 'source "/home/iac/.tenv/tenv_completion.bash"' \
        >> "${HOME}/.bashrc" \
    && echo 'source "/home/iac/.tenv/terraform-docs_completion.bash"' \
        >> "${HOME}/.bashrc" \
    && echo 'export PATH="/home/iac/awscli/bin:/home/iac/.tenv:/home/iac/.local/bin:${PATH}"' \
        >> "${HOME}/.bashrc"

# Terraform e Terragrunt
RUN tenv tf install latest
# RUN tenv tg install latest

# Informações das versões
ENV PATH=/home/iac/awscli/bin:/home/iac/.local/bin:${PATH}
RUN { \
        echo "Terraform: $(terraform version -json | jq -r '.terraform_version')"; \
        # echo "Terragrunt: $(terragrunt --version | cut -f 3 -d ' ')"; \
        echo "tenv: $(tenv --version | cut -f 3 -d ' ')"; \
        echo "TFLint: $(tflint --version | head -n 1 | cut -f 3 -d ' ')"; \
        echo "Trivy: $(trivy --version | head -n 1 | cut -f 2 -d ' ')"; \
        echo "Checkov: $(checkov --version | head -n 1)"; \
        echo "terraform-docs: $(terraform-docs --version | cut -f 3 -d ' ')"; \
        echo "pre-commit: $(pre-commit --version | head -n 1 | cut -f 2 -d ' ')"; \
        echo "AWS CLI: $(aws --version | head -n 1 | cut -f 1 -d ' ')"; \
        echo "Git: $(git --version | cut -f 3 -d ' ')"; \
        echo "Docker: $(docker --version | cut -f 3 -d ' ')"; \
        echo "Floci: $(floci --version | head -n 1 | cut -f 2 -d ' ')"; \
    } > "${HOME}/versions.txt"

# Workspace e script de inicialização
ENV TERM=xterm-256color
RUN echo "export PS1='\\[\\033[01;32m\\]\\u\\[\\033[00m\\]@\\[\\033[01;33m\\]nuvem-jt\\[\\033[00m\\]:\\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\$ '" >> ${HOME}/.bashrc

USER root

RUN mkdir -p /treinamento \
    && chown "${USERNAME}:${USERNAME}" /treinamento

COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

WORKDIR /treinamento

# Ferramentas adicionais
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       netcat-openbsd telnet dnsutils tree make gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Configurações gerais do git
RUN git config --system init.defaultBranch main \
    && git config --system user.email "iac@nuvem-jt" \
    && git config --system user.name "Treinamento IaC"

ENTRYPOINT ["/usr/local/bin/start.sh"]