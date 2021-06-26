import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = "";
  DateTime? _expiryDate;
  String _userId = "";

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyC9ZkoV_ctqR48K9dEtmL-fPS8UbXPH3Dg');
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
