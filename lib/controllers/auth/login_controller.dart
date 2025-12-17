import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flatten/app_constant.dart';
import 'package:flatten/controllers/my_controller.dart';
import 'package:flatten/helpers/services/auth_service.dart';
import 'package:flatten/helpers/widgets/my_form_validator.dart';
import 'package:flatten/helpers/widgets/my_validators.dart';
import 'package:flatten/myPages/customerHome.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flatten/models/user.dart';

class LoginController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false;
  bool loading = false;

  UserModel userModel = UserModel();
  String? userImage;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // fetchUser();
    basicValidator.addField(
      'email',
      required: true,
      label: "Email",
      validators: [MyEmailValidator()],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'password',
      required: true,
      label: "Password",
      validators: [MyLengthValidator(min: 6, max: 10)],
      controller: TextEditingController(),
    );
  }

  Future<UserModel?> fetchUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userId = pref.getString("email");
    if (userId != null) {
      UserModel? userModel = await fetchUserByValue(userId);
      return userModel;
    }
  }

  Future<String?> loginToERPNext(BuildContext context) async {
    loading = true;
    update();
    Map<String, dynamic> data = basicValidator.getData();
    String email = data['email'];
    String password = data['password'];
    var url = Uri.parse("$baseUrl/api/method/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usr": email, "pwd": password}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("body$body");
        String? sessionId = response.headers['set-cookie'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        if (sessionId != null) {
          await pref.setString("session_id", sessionId);
          await pref.setString("email", email);
          AuthService.sessionId = sessionId;
          toastMessage(message: "Login  Success");
          print("✅ Session stored: $sessionId");
          await fetchUserByValue(email);
          loading = false;
          update();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
          );
        }
      } else {
        toastMessage(message: "Login Failed: ${response.body}");
        loading = false;
        update();
        print('❌ Login failed: ${response.body}');
      }
    } catch (e) {
      loading = false;
      update();
      print('⚠️ Error during login: $e');
    }
    return null;
  }

  Future<UserModel?> fetchUserByValue(String value) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return null;
    }

    final url = Uri.parse(
      "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.get_customer_user_details?value=$value",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Cookie': AuthService.sessionId!,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? data;

        if (message is Map && message.containsKey('error')) {
          print("❌ Error: ${message['error']}");
          return null;
        }

        userModel = UserModel.fromJson(message);
        return userModel;
      } else {
        print("❌ HTTP Error ${response.statusCode}: ${response.body}");
      }
    } on SocketException {
      print("⚠️ Connection Error: Cannot reach backend ($baseUrl)");
    } catch (e) {
      print("⚠️ Unexpected Error: ${e.toString()}");
    }
  }

  Future<void> userLogOut() async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return;
    }

    final url = Uri.parse(
      "$baseUrl/api/method/my_api_app.api_methods.hr_modules_api.logout_user",
    );

    final response = await http.get(
      url,
      headers: {'Cookie': AuthService.sessionId!},
    );

    if (response.statusCode == 200) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove("session_id");
      response.body;
      // userModel = UserModel();
      print("✅ Logout successful");

      AuthService.sessionId = null;
    } else {
      print("❌ Logout failed: ${response.body}");
    }
  }

  Future<void> fetchImageBase64() async {
    String? imagePath = userModel.image;
    String? sessionId = AuthService.sessionId;

    if (sessionId != null && imagePath != null) {
      final url = Uri.parse(
        "$baseUrl/api/method/my_api_app.api_methods.hr_modules_api.user_image_base64?image_path=$imagePath&cookie=$sessionId",
      );

      print("url$url");
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          var value = data["message"];
          userImage = value['image_base64'];
          update();
        }
      } catch (e) {
        print("Error fetching image: $e");
      }
    }
  }
}
