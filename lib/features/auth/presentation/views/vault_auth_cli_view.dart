import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/components/console_text.dart';
import '../../../../core/common/components/console_text_field.dart';
import '../../../../core/constants/context_path.dart';
import '../../../../core/utils/flag_parser.dart';
import '../../../../init_dependencies.dart';
import '../../../vault/presentation/bloc/vault_bloc.dart';
import '../../../vault/presentation/views/vault_console_view.dart';
import '../bloc/vault_auth_bloc.dart';
import '../bloc/vault_auth_event.dart';
import '../bloc/vault_auth_state.dart';

class VaultAuthCliView extends StatefulWidget {
  const VaultAuthCliView({super.key});

  @override
  State<VaultAuthCliView> createState() => _VaultAuthCliViewState();
}

class _VaultAuthCliViewState extends State<VaultAuthCliView> {
  late final VaultAuthBloc _vaultAuthBloc;

  final ValueNotifier<List<String>> _consoleLines = ValueNotifier([
    'vault_cli v1.0',
    '',
    'Welcome to your offline CLI-based password vault manager.',
    'Current directory: auth',
    'Type `help` to see available commands.',
  ]);
  final ValueNotifier<String> _contextPath = ValueNotifier(ContextPath.auth);

  final _commandController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _vaultAuthBloc = context.read<VaultAuthBloc>();
  }

  void _appendLines(List<String> lines) {
    _consoleLines.value = [..._consoleLines.value, ...lines];
    _scrollToBottom();
  }

  void _appendLine(String line) => _appendLines([line]);

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _printUsage({
    required String usage,
    bool hasMoreThanOneFlag = true,
    bool isError = false,
  }) {
    _appendLines([
      if (isError)
        '[ERROR]: Missing required ${hasMoreThanOneFlag ? 'flags' : 'flag'}',
      'Usage:',
      usage,
    ]);
  }

  void _handleCommand(String input) {
    if (input.trim().isEmpty) return;

    final parts = input.trim().split(' ');
    final command = parts.first.toLowerCase();
    final args = parts.length > 1
        ? parts.sublist(1).cast<String>()
        : <String>[];

    switch (_contextPath.value) {
      case ContextPath.auth:
        _handleNormalMode(command, args);
        break;
      case ContextPath.recovery:
        _handleRecoveryAnswer(input);
        break;
      case ContextPath.recoverySetup:
        _handleRecoverySetup(command, args);
        break;
    }
  }

  void _handleNormalMode(String command, List<String> args) {
    switch (command) {
      case 'help':
        _appendLines([
          '',
          'Available Commands:',
          ' help        - See available commands',
          ' init        - Initialize vault',
          ' unlock      - Unlock vault',
          ' recovery    - Recover vault access',
          ' clear       - Clear the console',
          ' exit        - Exit the app',
          '',
          'Tip: Type command name + Enter to execute.',
        ]);
        break;
      case 'init':
        const usage =
            '  init -m <master password> -q <recovery question> -a <recovery answer>';

        if (args.isEmpty) {
          _printUsage(usage: usage);
          break;
        }

        final flags = flagParser(args);
        final masterPassword = flags['m'];
        final recoveryQuestion = flags['q'];
        final recoveryAnswer = flags['a'];

        if (masterPassword == null ||
            recoveryQuestion == null ||
            recoveryAnswer == null) {
          _printUsage(usage: usage, isError: true);
          break;
        }

        _vaultAuthBloc.add(
          InitializeVaultEvent(
            masterPassword: masterPassword,
            recoveryQuestion: recoveryQuestion,
            recoveryAnswer: recoveryAnswer,
          ),
        );
        break;
      case 'unlock':
        const usage = '  unlock -m <master password>';

        if (args.isEmpty) {
          _printUsage(usage: usage);
          break;
        }

        final flags = flagParser(args);
        final masterPassword = flags['m'];

        if (masterPassword == null) {
          _printUsage(usage: usage, hasMoreThanOneFlag: false, isError: true);
          break;
        }

        _vaultAuthBloc.add(UnlockVaultEvent(masterPassword: masterPassword));
        break;
      case 'recovery':
        _appendLines(['[RETRIEVING RECOVERY QUESTION...]']);
        _vaultAuthBloc.add(RetrieveVaultRecoveryQuestionEvent());
        break;
      case 'clear':
        _consoleLines.value = [
          'vault_cli v1.0',
          'Current directory: auth',
          'Type `help` to see available commands.',
        ];
        break;
      case 'exit':
        _exit();
        break;
      default:
        _appendLine('[UNKNOWN COMMAND]: $command');
    }
  }

  void _exit() async {
    _appendLine('[EXIT]: App will close in 3 seconds...');
    await Future.delayed(const Duration(seconds: 3));
    SystemNavigator.pop();
  }

  void _handleRecoveryAnswer(String input) {
    if (input == 'cd') {
      _contextPath.value = ContextPath.auth;
      return;
    }
    _vaultAuthBloc.add(VerifyVaultRecoveryAnswerEvent(recoveryAnswer: input));
  }

  void _handleRecoverySetup(String command, List<String> args) {
    if (command == 'cd') {
      _contextPath.value = ContextPath.recovery;
      return;
    }

    if (command == 'set' && args.isNotEmpty && args.first == 'new') {
      final flags = flagParser(args.sublist(1));
      final masterPassword = flags['m'];
      final recoveryQuestion = flags['q'];
      final recoveryAnswer = flags['a'];

      if (masterPassword == null) {
        _printUsage(
          usage:
              '  set new -m <master password> [-q <recovery question>] [-a <recovery  answer>]',
          isError: true,
        );
        return;
      }

      _vaultAuthBloc.add(
        SetupNewMasterPasswordEvent(
          newMasterPassword: masterPassword,
          newRecoveryQuestion: recoveryQuestion,
          newRecoveryAnswer: recoveryAnswer,
        ),
      );
    } else {
      _appendLine('[ERROR]: Invalid recovery setup command.');
    }
  }

  void _onSubmitted(String input) {
    if (input.trim().isEmpty) return;
    _appendLine('${_contextPath.value} $input');
    _commandController.clear();
    _handleCommand(input);
  }

  void _navigateToMainConsoleView() async {
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

  void _printAndRedirectSuccess(String action) {
    _appendLines([
      '[SUCCESS: $action',
      '',
      'Redirecting you to the main vault...',
    ]);
    _navigateToMainConsoleView();
  }

  @override
  void dispose() {
    _consoleLines.dispose();
    _contextPath.dispose();
    _commandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocListener<VaultAuthBloc, VaultAuthState>(
                listener: (context, state) {
                  if (state is VaultAuthInitialized) {
                    _printAndRedirectSuccess('Vault initialized!');
                  }

                  if (state is VaultAuthUnlocked) {
                    _printAndRedirectSuccess('Vault unlocked!');
                  }

                  if (state is VaultRetrievedRecoveryQuestion) {
                    _appendLines([
                      '[QUESTION]: ${state.recoveryQuestion}',
                      '',
                      'Please type your recovery answer and press Enter.',
                      'Tip: Type `cd` to cancel and go back.',
                    ]);
                    _contextPath.value = ContextPath.recovery;
                  }

                  if (state is VaultVerifiedRecoveryAnswer) {
                    if (state.isSuccessful) {
                      _appendLines([
                        '[SUCCESS]: Recovery answer verified!',
                        '',
                        'Next step: Set up a new master password.',
                        'You may also update your recovery question and answer during this process.',
                      ]);
                      _printUsage(
                        usage:
                            ' set new -m <master password> [-q <recovery question>] [-a <recovery answer>]',
                      );
                      _contextPath.value = ContextPath.recoverySetup;
                    } else {
                      _appendLines([
                        '[ERROR]: Incorrect recovery answer.',
                        '',
                        'Tip: Type your recovery answer again, or use `cd` to go back.',
                        'Warning: Use `reset` to initialize a new vault. This will erase all existing entries permanently.',
                      ]);
                    }
                  }

                  if (state is VaultAuthMasterPasswordUpdated) {
                    _printAndRedirectSuccess('Vault master password updated!');
                  }

                  if (state is VaultAuthError) {
                    _appendLine('[ERROR]: ${state.message}');
                  }
                },
                child: ValueListenableBuilder(
                  valueListenable: _consoleLines,
                  builder: (context, consoleLines, child) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: consoleLines.length,
                      itemBuilder: (context, index) {
                        final text = consoleLines[index];
                        return ConsoleText(text: text);
                      },
                    );
                  },
                ),
              ),
            ),
            ConsoleTextField(
              controller: _commandController,
              contextPath: _contextPath,
              onSubmitted: _onSubmitted,
            ),
          ],
        ),
      ),
    );
  }
}
