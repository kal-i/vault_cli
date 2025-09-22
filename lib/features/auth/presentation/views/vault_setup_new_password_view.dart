import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class VaultSetupNewPasswordView extends StatefulWidget {
  const VaultSetupNewPasswordView({super.key});

  @override
  State<VaultSetupNewPasswordView> createState() =>
      _VaultSetupNewPasswordViewState();
}

class _VaultSetupNewPasswordViewState extends State<VaultSetupNewPasswordView> {
  late final VaultAuthBloc _vaultAuthBloc;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _recoveryQuestionController = TextEditingController();
  final _recoveryAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vaultAuthBloc = context.read<VaultAuthBloc>();
  }

  void _confirm() {
    if (_formKey.currentState!.mounted) {
      if (_passwordController.text != _confirmPasswordController.text) {
        showSnackBar(
          context: context,
          message: 'Password and confirm password did not match',
        );
      } else {
        _vaultAuthBloc.add(
          SetupNewMasterPasswordEvent(
            newMasterPassword: _passwordController.text,
            newRecoveryQuestion: _recoveryQuestionController.text,
            newRecoveryAnswer: _recoveryAnswerController.text,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _recoveryQuestionController.dispose();
    _recoveryAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VaultAuthBloc, VaultAuthState>(
      listener: (context, state) async {
        if (state is VaultAuthSuccess) {
          showSnackBar(context: context, message: 'Password setup successful');

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

        if (state is VaultAuthError) {
          showSnackBar(context: context, message: state.message);
        }
      },
      child: VaultBaseAuthView(
        title: 'vault_cli >> recovery >> setup_new_password',
        mainChildWidget: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: _passwordController,
                label: 'Password',
              ),
              CustomTextFormField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
              ),
              CustomTextFormField(
                controller: _recoveryQuestionController,
                label: 'Recovery Question (Optional)',
              ),
              CustomTextFormField(
                controller: _recoveryAnswerController,
                label: 'Recovery Answer (Optional)',
              ),
            ],
          ),
        ),
        footerActionWidget: CustomFilledButton(
          onTap: _confirm,
          label: 'Confirm',
        ),
      ),
    );
  }
}
