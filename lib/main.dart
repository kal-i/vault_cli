import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/theme/app_theme.dart';
import 'core/services/secure_storage_service.dart';
import 'features/auth/presentation/bloc/vault_auth_bloc.dart';
import 'features/auth/presentation/views/vault_auth_view.dart';

import 'features/password_vault_console/data/data_sources/local/db_utils.dart';
import 'features/password_vault_console/data/data_sources/local/vault_database.dart';
import 'init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const VaultCLIApp());
}

class VaultCLIApp extends StatelessWidget {
  const VaultCLIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<VaultAuthBloc>(),
      child: MaterialApp(
        title: 'Password Vault Console',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.base,
        home: const VaultAuthView(),
      ),
    );
  }
}
