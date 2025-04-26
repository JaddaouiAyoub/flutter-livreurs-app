import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/api_response.dart';

class ApiService {
  static Future<ApiResponse> getEstimatedArrivalTime() async {
    final url = Uri.parse('https://blitz.free.beeceptor.com/riders/next');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final time = data['estimated_arrival_time'];
        return ApiResponse(success: true, message: time);
      } else {
        return ApiResponse(success: false, message: 'Erreur de récupération');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion');
    }
  }

  static Future<ApiResponse> requestLivreur(String phoneNumber) async {
    final url = Uri.parse('https://blitz.free.beeceptor.com/request');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Livreur demandé avec succès ✅',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur serveur (${response.statusCode})',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion ❌');
    }
  }

  static Future<ApiResponse> fetchRequests() async {
    final url = Uri.parse('https://blitz.free.beeceptor.com/requests');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(success: true, message: data);
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur récupération des demandes',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion');
    }
  }
}
