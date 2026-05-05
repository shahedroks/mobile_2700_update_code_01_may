import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/app_repository.dart';
import 'data/repositories/api_auth_repository.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final authRepository = ApiAuthRepository();
  final jobRepository = MemoryJobRepository();
  final authViewModel = AuthViewModel(authRepository);
  await authViewModel.loadSession();

  final router = AppRouter.create(authViewModel);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<JobRepository>.value(value: jobRepository),
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
      ],
      child: TruckFixApp(router: router),
    ),
  );
}

class TruckFixApp extends StatelessWidget {
  const TruckFixApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TruckFix',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
