FROM mcr.microsoft.com/devcontainers/base:jammy

# Install nodejs and npm
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends nodejs npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Install diff-so-fancy
RUN npm install -g diff-so-fancy

USER vscode

# Install foundry-zksync. Because piping the script to bash exits with error
# code 23, the install is performed in the postCreateCommand in devcontainer.json.
RUN curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync -o /tmp/install-foundry-zksync  

# Install foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    /home/vscode/.foundry/bin/foundryup

# Configure shell
RUN echo 'alias g=git' >> /home/vscode/.bash_aliases