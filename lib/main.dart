import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/theme/app_theme.dart';
import 'core/services/screenshot_service.dart';
import 'features/auth/presentation/bloc/vault_auth_bloc.dart';

import 'features/startup/presentation/bloc/startup_bloc.dart';
import 'features/startup/presentation/views/splash_screen_view.dart';
import 'init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await ScreenshotService.enable();
  runApp(const VaultCliApp());
}

class VaultCliApp extends StatelessWidget {
  const VaultCliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<StartupBloc>()..add(NavigateToEvent()),
        ),
        BlocProvider(create: (_) => serviceLocator<VaultAuthBloc>()),
      ],
      child: MaterialApp(
        title: 'Vault CLI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.base,
        home: const SplashScreenView(),
      ),
    );
  }
}
