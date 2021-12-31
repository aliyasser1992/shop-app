import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shopify1_app/models/http_exeptions.dart';

class Auth extends ChangeNotifier {
  String _token;
  // DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  Auth();

  bool get isAuth {
    return token != null;
  }

  String get token {
    //if (_expiryDate != null &&
    //   _expiryDate.isAfter(DateTime.now()) &&
    //   token != null) {
    return _token;
    // }
    //return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB_okhw7tezhLKt-UMKucIFkLka3P1E3wE';

    try {
      final res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpExeption(resData['error']['message']);
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      // _expiryDate = DateTime.now()
      // .add(Duration(seconds: int.parse(resData['expirseIn'])));
      // _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        //  'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (e) {
      throw (e);
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    // final exppiryDate = DateTime.parse(extractedData['expiryDate']);
    //if (exppiryDate.isBefore(DateTime.now())) return false;

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    //_expiryDate = exppiryDate;
    notifyListeners();
    // _autoLogOut();
    return true;
  }

  Future<bool> logOut() async {
    _token = null;
    _userId = null;
    //_expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  //void _autoLogOut() {
  //if (_authTimer != null) {
  //   _authTimer.cancel();
  // }
  //final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
  // _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  //}
}
