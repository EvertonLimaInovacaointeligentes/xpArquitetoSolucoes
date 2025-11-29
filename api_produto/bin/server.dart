import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import '../lib/infrastructure/di/dependency_injection.dart';

void main() async {
  // Injeção de dependências
  final handler = DependencyInjection.createProductHandler();
  
  // Handler para servir arquivos estáticos do Swagger
  final staticHandler = createStaticHandler(
    'swagger',
    defaultDocument: 'index.html',
  );

  // Router principal
  final app = Router();
  
  // Rota raiz
  app.get('/', (Request request) {
    return Response.ok(
      'API de Produtos - Acesse /swagger para documentação',
      headers: {'Content-Type': 'text/plain'},
    );
  });
  
  // Rota para Swagger UI
  app.mount('/swagger', staticHandler);
  
  // Rotas da API de produtos
  app.mount('/', handler.router.call);

  final cascade = Cascade()
      .add(app.call);

  // Middleware para CORS
  final corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  Handler middleware(Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }
      final response = await handler(request);
      return response.change(headers: corsHeaders);
    };
  }

  final server = await io.serve(
    middleware(cascade.handler),
    InternetAddress.anyIPv4,
    8080,
  );

  print('🚀 Servidor rodando em http://${server.address.host}:${server.port}');
  print('\n📚 Documentação Swagger: http://${server.address.host}:${server.port}/swagger/');
  print('\n📋 Endpoints disponíveis:');
  print('GET    /products       - Listar todos os produtos');
  print('GET    /products/<id>  - Buscar produto por ID');
  print('POST   /products       - Criar novo produto');
  print('PUT    /products/<id>  - Atualizar produto');
  print('DELETE /products/<id>  - Deletar produto');
}
