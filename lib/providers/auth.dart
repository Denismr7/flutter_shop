import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = "";
  DateTime? _expiryDate;
  String _userId = "";
  final authKey = dotenv.env['FIREBASE_AUTH_API'];

  bool get isAuth {
    return token.isNotEmpty;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token.isNotEmpty) {
      return _token;
    }
    return "";
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$authKey');
    try {
      final request = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final requestDecoded = json.decode(request.body);
      if (requestDecoded['error'] != null) {
        throw HttpException(requestDecoded['error']['message']);
      }
      _token = requestDecoded['idToken'];
      _userId = requestDecoded['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(requestDecoded['expiresIn']),
        ),
      );
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
