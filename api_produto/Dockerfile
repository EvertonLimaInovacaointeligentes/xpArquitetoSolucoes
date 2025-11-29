# Usar imagem oficial do Dart
FROM dart:stable AS build

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY pubspec.* ./

# Instalar dependências
RUN dart pub get

# Copiar código fonte
COPY . .

# Compilar a aplicação para executável nativo
RUN dart compile exe bin/server.dart -o bin/server

# Usar imagem mínima para produção
FROM scratch

# Copiar executável compilado
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/swagger /app/swagger/

# Definir diretório de trabalho
WORKDIR /app

# Expor porta
EXPOSE 8080

# Comando para executar
ENTRYPOINT ["/app/bin/server"]
