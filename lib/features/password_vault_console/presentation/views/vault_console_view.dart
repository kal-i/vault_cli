import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../init_dependencies.dart';
import '../bloc/vault_bloc.dart';
import '../components/console_text.dart';
import '../components/console_text_field.dart';

class VaultConsoleView extends StatefulWidget {
  const VaultConsoleView({super.key});

  @override
  State<VaultConsoleView> createState() => _VaultConsoleViewState();
}

class _VaultConsoleViewState extends State<VaultConsoleView> {
  final ValueNotifier<List<String>> _consoleLines = ValueNotifier([
    '[INITIALIZING VAULT ENVIRONMENT...]',
    '[SECURE PASSWORD MANAGER v1.0]',
    '',
    'Welcome to Password Vault CLI.',
    'Type \'help\' to see available commands.',
  ]);

  final _commandController = TextEditingController();
  final _scrollController = ScrollController();

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

  Map<String, String?> _parseFlags(List<String> args) {
    final result = <String, String?>{};
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (arg.startsWith('-')) {
        final key = arg.substring(1);
        if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
          result[key] = args[i + 1];
          i++;
        } else {
          result[key] = null;
        }
      }
    }
    return result;
  }

  void _printUsage() {
    _appendLines([
      'Usage:',
      ' add -t <title> -p <password> [-u <username>] [-e <email>] [-c <contact>] [-n <notes>]',
      ' update <id> [-t <title>] [-p <password>] [-u <username>] [-e <email>] [-c <contact>] [-n <notes>]',
    ]);
  }

  void _handleCommand(String input) {
    if (input.trim().isEmpty) return;

    final vaultBloc = context.read<VaultEntryBloc>();
    final parts = input.trim().split(' ');
    final command = parts.first.toLowerCase();
    final args = parts.length > 1
        ? parts.sublist(1).cast<String>()
        : <String>[];

    switch (command) {
      case 'help':
        _appendLines([
          '',
          'Available Commands:',
          ' add               - Add a new entry',
          ' list              - Show all stored entries',
          ' list <title>      - Show entries by title',
          ' get <id>          - Retrieve and copy password',
          ' update <name>     - Update an existing entry',
          ' delete <id>       - Delete an entry',
          ' lock              - Lock the vault',
          ' clear             - Clear the screen',
          ' exit              - Exit the app',
          '',
          'Tip: Type command name + Enter to execute.',
        ]);
        break;
      case 'add':
        final flags = _parseFlags(args);
        final title = flags['t'];
        final password = flags['p'];

        if (title == null || password == null) {
          _appendLine('[ERROR]: Missing required flags.');
          _printUsage();
          break;
        }

        vaultBloc.add(
          AddVaultEntryEvent(
            title: title,
            password: password,
            username: flags['u'],
            email: flags['e'],
            contactNo: flags['c'],
            notes: flags['n'],
          ),
        );
        break;
      case 'list':
        if (args.isNotEmpty) {
          final title = args.first;
          vaultBloc.add(GetVaultEntriesByTitleEvent(title: title));
        } else {
          vaultBloc.add(GetAllVaultEntriesEvent());
        }
        break;
      case 'get':
        if (args.isEmpty) {
          _appendLine('[ERROR]: Missing <id> argument');
        } else {
          final id = args.first;
          vaultBloc.add(GetVaultEntryByIdEvent(id: id));
        }
        break;
      case 'delete':
        if (args.isEmpty) {
          _appendLine('[ERROR]: Missing <id> argument');
        } else {
          final id = args.first;
          vaultBloc.add(DeleteVaultEntryEvent(id: id));
        }
        break;
      case 'clear':
        _consoleLines.value = [];
        break;
      case 'exit':
        _appendLine('[EXISTING...]');
        break;
      default:
        _appendLine('[UNKNOWN COMMAND: $command]');
    }
  }

  void _onSubmitted(String input) {
    if (input.trim().isEmpty) return;
    _appendLine('vault> $input');
    _commandController.clear();
    _handleCommand(input);
  }

  @override
  void dispose() {
    _consoleLines.dispose();
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
              child: BlocListener<VaultEntryBloc, VaultState>(
                listener: (context, state) {
                  if (state is LoadingVault) {
                    _appendLine('[PROCESSING REQUEST...]');
                  } else if (state is LoadedVault) {
                    _appendLine(
                      '[FETCHED ${state.vaultEntryEntities.length} ENTRIES]',
                    );
                    for (final entry in state.vaultEntryEntities) {
                      _appendLine('• ${entry.title} (${entry.id})');
                    }
                  } else if (state is EntryLoaded) {
                    if (state.vaultEntryEntity != null) {
                      _appendLine(
                        '[ENTRY FOUND: ${state.vaultEntryEntity!.title}]',
                      );
                    } else {
                      _appendLine('[ENTRY NOT FOUND]');
                    }
                  } else if (state is ErrorVault) {
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
              onSubmitted: _onSubmitted,
            ),
          ],
        ),
      ),
    );
  }
}
