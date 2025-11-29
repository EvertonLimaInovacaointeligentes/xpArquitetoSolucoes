import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/product_controller.dart';
import '../dto/product_dto.dart';

/// Handler HTTP - Camada de apresentação
/// Responsável por receber requisições HTTP e retornar respostas
class ProductHandler {
  final ProductController controller;

  ProductHandler(this.controller);

  Router get router {
    final router = Router();

    router.get('/products', _getAll);
    router.get('/products/<id>', _getById);
    router.post('/products', _create);
    router.put('/products/<id>', _update);
    router.delete('/products/<id>', _delete);

    return router;
  }

  Future<Response> _getAll(Request request) async {
    try {
      final products = await controller.getAllProducts();
      final dtos = products.map((p) => ProductDto.fromEntity(p).toJson()).toList();
      
      return Response.ok(
        jsonEncode(dtos),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao buscar produtos'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getById(Request request, String id) async {
    try {
      final product = await controller.getProductById(id);
      
      if (product == null) {
        return Response.notFound(
          jsonEncode({'error': 'Produto não encontrado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final dto = ProductDto.fromEntity(product);
      return Response.ok(
        jsonEncode(dto.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao buscar produto'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _create(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final product = await controller.createProduct(
        name: data['name'] as String,
        price: (data['price'] as num).toDouble(),
        quantity: data['quantity'] as int,
      );

      final dto = ProductDto.fromEntity(product);
      return Response(
        201,
        body: jsonEncode(dto.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _update(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final product = await controller.updateProduct(
        id: id,
        name: data['name'] as String,
        price: (data['price'] as num).toDouble(),
        quantity: data['quantity'] as int,
      );

      if (product == null) {
        return Response.notFound(
          jsonEncode({'error': 'Produto não encontrado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final dto = ProductDto.fromEntity(product);
      return Response.ok(
        jsonEncode(dto.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _delete(Request request, String id) async {
    try {
      final deleted = await controller.deleteProduct(id);
      
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'error': 'Produto não encontrado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({'message': 'Produto deletado com sucesso'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao deletar produto'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
