import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/issue_model.dart';
import 'package:mobile_app/models/issue_details_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  Future<IssueDetails> fetchIssue(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/issues/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return IssueDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load issue');
    }
  }

  Future<List<Issue>> fetchIssues() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/issues'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Issue>.from(l.map((model) => Issue.fromJson(model)));
    } else {
      throw Exception('Failed to load issues');
    }
  }

  Future<List<Issue>> fetchReportedIssues() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/issues/reported'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Issue>.from(l.map((model) => Issue.fromJson(model)));
    } else {
      throw Exception('Failed to load reported issues');
    }
  }

  Future<String> fetchImage(String imageId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/images/$imageId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['base64String'];
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> signIn(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final userRole = decodedToken['role'];
      final userId = decodedToken['_id'];
      print('Token: $token');
      print('User Role: $userRole');
      print('User ID: $userId');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userRole', userRole);
      await prefs.setString('userId', userId);
    } else {
      throw Exception('Failed to sign in');
    }
  }

  Future<void> signUp(
      String name, String surname, String email, String password) async {
    final String username = '$name';
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
    } else {
      throw Exception('Failed to sign up ${response.body}');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> updateIssueStatusToInProgress(String issueId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.patch(
      Uri.parse('$baseUrl/issues/$issueId/in_progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update issue status to in progress');
    }
  }

  Future<void> updateIssueStatusToResolved(String issueId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.patch(
      Uri.parse('$baseUrl/issues/$issueId/resolve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update issue status to resolved');
    }
  }

  // Upvote and Downvote Issue
  Future<void> upvoteIssue(String issueId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.patch(
      Uri.parse('$baseUrl/issues/$issueId/upvote'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to upvote the issue: ${jsonDecode(response.body)['error']}');
    }
  }

  Future<void> downvoteIssue(String issueId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.patch(
      Uri.parse('$baseUrl/issues/$issueId/downvote'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to downvote the issue: ${jsonDecode(response.body)['error']}');
    }
  }
}
