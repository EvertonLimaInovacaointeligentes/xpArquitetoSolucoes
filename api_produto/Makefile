.PHONY: help install run test docker-build docker-up docker-down docker-logs clean

help: ## Mostrar ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Instalar dependências
	dart pub get

run: ## Executar aplicação localmente
	dart run bin/server.dart

test: ## Executar testes
	dart test

test-coverage: ## Executar testes com cobertura
	dart test --coverage=coverage
	dart pub global activate coverage
	dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

docker-build: ## Construir imagem Docker
	docker-compose build

docker-up: ## Iniciar container
	docker-compose up -d

docker-down: ## Parar container
	docker-compose down

docker-logs: ## Ver logs do container
	docker-compose logs -f

docker-restart: ## Reiniciar container
	docker-compose restart

docker-rebuild: ## Reconstruir e reiniciar
	docker-compose up -d --build

clean: ## Limpar arquivos gerados
	rm -rf .dart_tool build coverage
