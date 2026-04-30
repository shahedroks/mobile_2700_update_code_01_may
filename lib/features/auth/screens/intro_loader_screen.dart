import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/app_repository.dart';
import '../logic/splash_login_check.dart';

/// Session bootstrap before the rest of the auth stack.
class IntroLoaderScreen extends StatefulWidget {
  const IntroLoaderScreen({super.key});

  @override
  State<IntroLoaderScreen> createState() => _IntroLoaderScreenState();
}

class _IntroLoaderScreenState extends State<IntroLoaderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    if (!mounted) return;
    final auth = context.read<AuthRepository>();
    final next = await resolvePostSplashLocation(auth);
    if (!mounted) return;
    context.go(next);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFFBBF24)),
      ),
    );
  }
}
