#!/bin/bash

set -e

# Configuração do usuário
USERNAME="iac"
# Permite sobrescrever explicitamente o uid do usuário:
#   -e HOST_UID=1001
# Caso não informados, utiliza o proprietário de /treinamento.
if [ -z "${HOST_UID:-}" ]; then
    HOST_UID="$(stat -c '%u' /treinamento)"
fi

# Ajuste do UID caso o UID do host docker seja diferente do usuário do container.
CURRENT_UID="$(id -u "${USERNAME}")"
if [ "${CURRENT_UID}" != "${HOST_UID}" ]; then
    EXISTING_USER="$(getent passwd "${HOST_UID}" | cut -d: -f1 || true)"
    if [ -n "${EXISTING_USER}" ] && [ "${EXISTING_USER}" != "${USERNAME}" ]; then
        echo "ERROR: UID ${HOST_UID} já está em uso por '${EXISTING_USER}'."
        exit 1
    fi
    echo "⚠️  O UID do usuário no host docker é diferente do UID do usuário 'iac' no container."
    echo " Ajustando UID para evitar problemas de permissão com arquivos montados do host."
    echo "Atualizando UID do usuário ${USERNAME} no container: ${CURRENT_UID} -> ${HOST_UID}"
    echo "Aguarde... esta operação pode demorar, pois será realizada a atualização de UID de todos os arquivos do usuário."
    echo "Como alternativa para inicialização rápida, avalie executar o container com o usuário de UID 1000 no host docker."
    usermod \
        --uid "${HOST_UID}" \
        "${USERNAME}"
fi

# Corrige ownership dos arquivos do HOME criados durante o build.
chown ${HOST_UID} /home/iac
chown ${HOST_UID} /home/iac/*
chown -R "${HOST_UID}" /home/iac/.tenv
# chown -R \
#     "${HOST_UID}" \
#     "/home/${USERNAME}"

echo "===================================================================="
echo "  Capacitação IaC - Aplicações Nacionais - CCoE/CSJT"
echo "===================================================================="

echo "Starting Docker daemon (docker-in-docker) ..."
groupadd -f docker
dockerd \
    --group docker \
    --storage-driver=vfs \
    > /tmp/dockerd.log 2>&1 &
DOCKER_PID=$!
until docker info >/dev/null 2>&1; do
    if ! kill -0 "${DOCKER_PID}" 2>/dev/null; then
        echo "ERROR: Docker daemon failed to start."
        cat /tmp/dockerd.log
        exit 1
    fi
    sleep 1
done

echo "Starting AWS local emulator (Floci) ..."
floci start > /tmp/floci.log 2>&1 &
FLOCI_PID=$!
sleep 1
if ! kill -0 "${FLOCI_PID}" 2>/dev/null; then
    echo "WARNING: Floci failed to start."
    cat /tmp/floci.log
fi

# Modo devcontainer
if [ "${DEVCONTAINER:-false}" = "true" ]; then
    echo "Starting VS Code devcontainer..."
    echo "⚠️  Ambiente de treinamento com simplificações para fins didáticos."
    echo "Não deve ser utilizado como ambiente de desenvolvimento persistente."
    echo "===================================================================="
    exec tail -f /dev/null
fi

# Modo docker run
echo "Starting interactive Bash shell..."
echo "⚠️  Ambiente de treinamento com simplificações para fins didáticos."
echo "Não deve ser utilizado como ambiente de desenvolvimento persistente."
echo "===================================================================="
exec gosu iac /bin/bash --login