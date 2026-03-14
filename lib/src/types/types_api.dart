import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokedex/src/core/request_builder.dart';

class TypesApi {
  const TypesApi({required this.httpClient});

  TypesApi.create() : httpClient = http.Client();

  final http.Client httpClient;

  /// Lists all Pokémon types.
  Future<List<dynamic>?> listTypes({required String baseUrl}) async {
    final request = GetRequestBuilder('$baseUrl/type').acceptJson().build();

    try {
      final response = await httpClient.send(request);
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        return data['results'] as List<dynamic>;
      }

      print('Error fetching types: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Exception while fetching types: $e');
      return null;
    }
  }

  /// Gets details of a specific type, including Pokémon of that type.
  Future<Map<String, dynamic>?> getType({
    required String baseUrl,
    required String name,
  }) async {
    final request = GetRequestBuilder(
      '$baseUrl/type/$name',
    ).acceptJson().build();

    try {
      final response = await httpClient.send(request);
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }

      if (response.statusCode == 404) {
        print('Type not found: $name');
        return null;
      }

      print('Error fetching type: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Exception while fetching type: $e');
      return null;
    }
  }
}
