import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../init_dependencies.dart';
import '../../../password_vault_console/presentation/bloc/vault_bloc.dart';
import '../../../password_vault_console/presentation/views/vault_console_view.dart';
import '../bloc/vault_auth_bloc.dart';
import '../bloc/vault_auth_event.dart';
import '../bloc/vault_auth_state.dart';

class VaultAuthView extends StatefulWidget {
  const VaultAuthView({super.key});

  @override
  State<VaultAuthView> createState() => _VaultAuthViewState();
}

class _VaultAuthViewState extends State<VaultAuthView> {
  late final VaultAuthBloc _vaultAuthBloc;

  final _formKey = GlobalKey<FormState>();
  final _masterPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vaultAuthBloc = context.read<VaultAuthBloc>();
  }

  void _setup() {
    if (_formKey.currentState!.validate()) {
      _vaultAuthBloc.add(
        InitializeVaultEvent(masterPassword: _masterPasswordController.text),
      );
    }
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _vaultAuthBloc.add(
        UnlockVaultEvent(masterPassword: _masterPasswordController.text),
      );
    }
  }

  @override
  void dispose() {
    _masterPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocListener<VaultAuthBloc, VaultAuthState>(
      listener: (context, state) {
        if (state is VaultAuthSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => serviceLocator<VaultEntryBloc>(),
                child: const VaultConsoleView(),
              ),
            ),
          );
        }

        if (state is VaultAuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 15.0,
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _masterPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Master Password',
                  ),
                ),
              ),
              Row(
                spacing: 10.0,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _setup,
                      child: Text('Setup', style: textTheme.bodyMedium),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text('Login', style: textTheme.bodyMedium),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
