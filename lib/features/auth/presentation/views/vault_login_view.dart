import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_color.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_text_form_field.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../init_dependencies.dart';
import '../../../vault/presentation/bloc/vault_bloc.dart';
import '../../../vault/presentation/views/vault_console_view.dart';
import '../bloc/vault_auth_bloc.dart';
import '../bloc/vault_auth_event.dart';
import '../bloc/vault_auth_state.dart';
import 'vault_base_auth_view.dart';
import 'vault_password_recovery_view.dart';

class VaultLoginView extends StatefulWidget {
  const VaultLoginView({super.key});

  @override
  State<VaultLoginView> createState() => _VaultLoginViewState();
}

class _VaultLoginViewState extends State<VaultLoginView> {
  late final VaultAuthBloc _vaultAuthBloc;

  final _formKey = GlobalKey<FormState>();
  final _masterPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vaultAuthBloc = context.read<VaultAuthBloc>();
  }

  void _unlock() {
    if (_formKey.currentState!.validate()) {
      _vaultAuthBloc.add(
        UnlockVaultEvent(masterPassword: _masterPasswordController.text),
      );
    }
  }

  void _retrieveRecoveryQuestion() =>
      _vaultAuthBloc.add(RetrieveVaultRecoveryQuestionEvent());

  @override
  void dispose() {
    _masterPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VaultAuthBloc, VaultAuthState>(
      listener: (context, state) async {
        if (state is VaultAuthSuccess) {
          showSnackBar(context: context, message: 'Vault unlocked!');

          await Future.delayed(const Duration(seconds: 3));

          if (!context.mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => serviceLocator<VaultBloc>(),
                child: const VaultConsoleView(),
              ),
            ),
          );
        }

        if (state is VaultRetrievedRecoveryQuestion) {
          showSnackBar(
            context: context,
            message: 'Recovery question retrieved.',
          );

          await Future.delayed(const Duration(seconds: 3));

          if (!context.mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VaultPasswordRecoveryView(
                recoveryQuestion: state.recoveryQuestion,
              ),
            ),
          );
        }

        if (state is VaultAuthError) {
          showSnackBar(context: context, message: state.message);
        }
      },
      child: VaultBaseAuthView(
        title: 'vault_cli >> unlock',
        mainChildWidget: Column(
          children: [
            Form(
              key: _formKey,
              child: CustomTextFormField(
                controller: _masterPasswordController,
                label: 'Master Password',
                isObscured: true,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _retrieveRecoveryQuestion,
                child: Text('Forgot Master Password?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.lavender,
                ),),
              ),
            ),
          ],
        ),
        footerActionWidget: CustomFilledButton(onTap: _unlock, label: 'Unlock'),
      ),
    );
  }
}
