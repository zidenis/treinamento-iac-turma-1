## Dev Containers

O Dev Container é um ambiente de desenvolvimento executado dentro de um container Docker e configurado como código, permitindo padronizar ferramentas, dependências e configurações do projeto. Com integração ao VS Code, oferece um ambiente reprodutível, isolado e consistente, reduzindo a necessidade de instalar e configurar as ferramentas diretamente no computador do desenvolvedor.

### Atividades

1. Instale a extensão "Dev Containers" no VS Code. 
    ```url
    https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
    ```
1. O Dev Container é configurado através do arquivo `.devcontainer/devcontainer.json`.
    
    Este arquivo define a imagem base, extensões do VS Code, variáveis de ambiente e scripts de inicialização. Verifique o conteúdo do arquivo `.devcontainer/devcontainer.json` para entender como o ambiente está configurado.
    ```sh
    cd /treinamento/
    cat dia-1/1.09-vscode-devcontainer/.devcontainer/devcontainer.json
    ```
1. Abra a pasta `dia-1/1.09-vscode-devcontainer/` no VS Code (Open Folder, CTRL+K CTRL+O).

    Ao abrir a pasta, o VS Code detectará a presença do arquivo `.devcontainer/devcontainer.json`. Clique no botão `Reopen in Container` no canto inferior direito. O VS Code irá construir e iniciar o Dev Container com base na configuração definida no. Aguarde a conclusão do processo de construção e inicialização do container.

1. Abra o terminal e verifique se o Dev Container está funcionando corretamente. Abra o terminal integrado do VS Code e verifique se o emulador do floci está disponível:
    ```sh
    floci status
    eval $(floci env)
    ```
1. Teste o ambiente.
    ```sh
    terraform init
    terraform plan
    terraform apply
    aws s3 ls
    curl $(terraform output -raw website_URL) -w "\n"
    terraform destroy
    ```
