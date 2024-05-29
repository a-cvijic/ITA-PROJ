import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/issue_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/issues';

  Future<Issue> fetchIssue(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Issue.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load issue');
    }
  }
}
