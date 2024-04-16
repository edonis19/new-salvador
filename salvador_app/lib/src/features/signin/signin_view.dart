import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:salvador_task_management/src/config/navigation/navigation_service.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/features/main_view/main_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salvador_task_management/src/features/menu/user_menu_controller.dart';

const users = {
  'admin': 'admin',
  'icoldo': 'icoldo',
  'salvador': 'salvador',
  'OP1': 'tecnico1',
};

// Map associating user names with operator names
const operatorNames = {
  'admin': 'ADMIN',
  'icoldo': 'ICOLDO',
  'salvador': 'SALVADOR',
  'op1': 'OP1',
};

class SignInView extends ConsumerWidget {
  const SignInView({super.key});

  static const routeName = '/signin';

  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<String?> _onLogin(LoginData data, WidgetRef ref) {
    return Future.delayed(loginTime).then((_) async {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }

      final prefs = ref.read(sharedPreferencesProvider).asData!.value;
      await prefs.setString("user", data.name);

      final userMenuController = ref.read(userMenuControllerProvider.notifier);
      userMenuController.loadUserMenu();

      // Pass the operator name to ArticoliInterventoDataSource
      //ref.read(navigationServiceProvider).routeTo(MainView.routeName, arguments: data.name); 
      
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlutterLogin(
      logo: const AssetImage('assets/images/logo_icoldo.png'),
      onLogin: (loginData) async => await _onLogin(loginData, ref),
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () => {
        ref.read(navigationServiceProvider).routeTo(MainView.routeName)
      },
      onRecoverPassword: _recoverPassword,
      userValidator: (user) => null,
      userType: LoginUserType.name,
      theme: LoginTheme(
        primaryColor: const Color.fromARGB(255, 228, 186, 124),
      ),
    );
  }

}