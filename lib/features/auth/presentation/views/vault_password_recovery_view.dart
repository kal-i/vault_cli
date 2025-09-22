import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_text_form_field.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../bloc/vault_auth_bloc.dart';
import '../bloc/vault_auth_event.dart';
import '../bloc/vault_auth_state.dart';
import 'vault_base_auth_view.dart';
import 'vault_setup_new_password_view.dart';

class VaultPasswordRecoveryView extends StatefulWidget {
  const VaultPasswordRecoveryView({super.key, required this.recoveryQuestion});

  final String recoveryQuestion;

  @override
  State<VaultPasswordRecoveryView> createState() =>
      _VaultPasswordRecoveryViewState();
}

class _VaultPasswordRecoveryViewState extends State<VaultPasswordRecoveryView> {
  late final VaultAuthBloc _vaultAuthBloc;

  final _formKey = GlobalKey<FormState>();
  final _recoveryAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vaultAuthBloc = context.read<VaultAuthBloc>();
  }

  void _verifyRecoveryPassword() {
    if (_formKey.currentState!.validate()) {
      _vaultAuthBloc.add(
        VerifyVaultRecoveryAnswerEvent(
          recoveryAnswer: _recoveryAnswerController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _recoveryAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediumTextStyle = Theme.of(context).textTheme.bodyMedium;

    return BlocListener<VaultAuthBloc, VaultAuthState>(
      listener: (context, state) async {
        if (state is VaultVerifiedRecoveryAnswer) {
          if (state.isSuccessful) {
            showSnackBar(
              context: context,
              message: 'Recovery answer verified!',
            );

            await Future.delayed(const Duration(seconds: 3));

            if (!context.mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const VaultSetupNewPasswordView(),
              ),
            );
          } else {
            showSnackBar(
              context: context,
              message: 'Recovery answer verification failed!',
            );
          }
        }

        if (state is VaultAuthError) {
          showSnackBar(context: context, message: state.message);
        }
      },
      child: VaultBaseAuthView(
        title: 'vault_cli >> recovery',
        mainChildWidget: Column(
          children: [
            RichText(
              text: TextSpan(
                text: 'Question: ',
                style: mediumTextStyle?.copyWith(fontWeight: FontWeight.w900),
                children: [
                  TextSpan(
                    text: widget.recoveryQuestion,
                    style: mediumTextStyle,
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: CustomTextFormField(
                controller: _recoveryAnswerController,
                label: 'Recovery Answer',
              ),
            ),
          ],
        ),
        footerActionWidget: CustomFilledButton(
          onTap: _verifyRecoveryPassword,
          label: 'Verify',
        ),
      ),
    );
  }
}
