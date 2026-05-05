import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/app_repository.dart';
import '../logic/splash_login_check.dart';
import 'truckfix_loading_screen.dart';

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
    final nextFuture = resolvePostSplashLocation(auth);
    final minFuture = Future<void>.delayed(const Duration(milliseconds: 2200));
    final next = await nextFuture;
    await minFuture;
    if (!mounted) return;
    context.go(next);
  }

  @override
  Widget build(BuildContext context) {
    return const TruckFixLoadingScreen();
  }
}
