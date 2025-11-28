import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // get user details using dio
  final Dio _dio = Dio();
  final auth_api_url = dotenv.env['AUTH_API_URL'];
  Map<String, dynamic>? userData;

  Future<void> _fetchUserData() async {
    try {
      debugPrint("debug: Fetching user data from $auth_api_url/user-details");
      final response = await _dio.get('$auth_api_url/user-details',
          queryParameters: {
            "username": "yeshaya",
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json"
            },
          ));
      if (response.statusCode == 200) {
        setState(() {
          userData = response.data;
        });
      } else {
        debugPrint('Failed to load user data');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Page'),
      ),
      body: Center(
        child: userData == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Username: ${userData!['username']}'),
                  Text('Email: ${userData!['email']}'),
                ],
              ),
      ),
    );
  }
}
