# Imagem customizada do Jenkins com Dart e Docker
FROM jenkins/jenkins:lts

USER root

# Instalar dependências
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Instalar Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Instalar Dart SDK
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | tee /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && \
    apt-get install -y dart && \
    rm -rf /var/lib/apt/lists/*

# Adicionar Dart ao PATH
ENV PATH="${PATH}:/usr/lib/dart/bin:/root/.pub-cache/bin"

# Adicionar usuário jenkins ao grupo docker
RUN usermod -aG docker jenkins

USER jenkins

# Instalar plugins recomendados
RUN jenkins-plugin-cli --plugins \
    git \
    docker-workflow \
    pipeline-stage-view \
    blueocean \
    workflow-aggregator \
    credentials-binding \
    timestamper \
    ws-cleanup

# Expor porta
EXPOSE 8080 50000
