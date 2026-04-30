import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:truckfix/data/repositories/app_repository.dart';
import 'package:truckfix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:truckfix/main.dart';
import 'package:truckfix/routes/app_router.dart';

void main() {
  testWidgets('TruckFixApp builds', (WidgetTester tester) async {
    final authRepository = MemoryAuthRepository();
    final jobRepository = MemoryJobRepository();
    final authViewModel = AuthViewModel(authRepository);
    await authViewModel.loadSession();
    final router = AppRouter.create(authViewModel);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          Provider<JobRepository>.value(value: jobRepository),
          ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ],
        child: TruckFixApp(router: router),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
