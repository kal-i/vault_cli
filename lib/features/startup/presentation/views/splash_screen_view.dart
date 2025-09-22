import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/views/vault_login_view.dart';
import '../../../auth/presentation/views/vault_setup_view.dart';
import '../bloc/startup_bloc.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<StartupBloc, StartupState>(
      listener: (context, state) async {
        await Future.delayed(const Duration(seconds: 3));
        if (state is StartupToSetup) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VaultSetupView()),
          );
        }

        if (state is StartupToLogin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VaultLoginView()),
          );
        }
      },
      child: const CircularProgressIndicator(),
    );
  }
}
