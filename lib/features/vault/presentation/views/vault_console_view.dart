import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../init_dependencies.dart';
import '../../domain/entity/vault_entry_entity.dart';
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
    'vault_cli v1.0',
    '',
    'Welcome to your offline CLI-based password vault.',
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

        // For -n flag, capture all words or until next flag
        if (key == 'n') {
          final buffer = <String>[];
          i++;
          while (i < args.length && !args[i].startsWith('-')) {
            buffer.add(args[i]);
            i++;
          }
          i--;
          result[key] = buffer.join(' ');
        } else {
          if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
            result[key] = args[i + 1];
            i++;
          } else {
            result[key] = null;
          }
        }
      }
    }
    return result;
  }

  void _printUsage({required String usage, bool hasMoreThanOneFlag = true}) {
    _appendLines([
      '[ERROR]: Missing required ${hasMoreThanOneFlag ? 'flags' : 'flag'}',
      'Usage:',
      usage,
    ]);
  }

  void _handleCommand(String input) {
    if (input.trim().isEmpty) return;

    final vaultBloc = context.read<VaultBloc>();
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
          ' list -t <title>   - Show entries by title',
          ' get -i <id>       - Retrieve an entry',
          ' update -i <id>    - Update an existing entry',
          ' delete -i <id>    - Delete an entry',
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
          _printUsage(
            usage:
                ' add -t <title> -p <password> [-u <username>] [-e <email>] [-c <contact>] [-n <notes>]',
          );
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
          final flag = _parseFlags(args);
          final title = flag['t'];

          if (title == null) {
            _printUsage(usage: ' list -t <title>', hasMoreThanOneFlag: false);
            break;
          }

          vaultBloc.add(GetVaultEntriesByTitleEvent(title: title));
        } else {
          vaultBloc.add(GetAllVaultEntriesEvent());
        }
        break;
      case 'get':
        final flag = _parseFlags(args);
        final id = flag['i'];

        if (id == null) {
          _printUsage(usage: '  get -i <id>', hasMoreThanOneFlag: false);
          break;
        }

        vaultBloc.add(GetVaultEntryByIdEvent(id: id));
        break;
      case 'update':
        final flags = _parseFlags(args);
        final id = flags['i'];

        if (id == null) {
          _printUsage(
            usage:
                ' update -i <id> [-t <title>] [-p <password>] [-u <username>] [-e <email>] [-c <contact>] [-n <notes>]',
          );
          break;
        }

        vaultBloc.add(
          UpdateVaultEntryEvent(
            id: id,
            title: flags['t'],
            password: flags['p'],
            username: flags['u'],
            email: flags['e'],
            contactNo: flags['c'],
            notes: flags['n'],
          ),
        );
        break;
      case 'delete':
        final flags = _parseFlags(args);
        final id = flags['i'];

        if (id == null) {
          _printUsage(usage: '  delete -i <id>', hasMoreThanOneFlag: false);
          break;
        }
        vaultBloc.add(DeleteVaultEntryEvent(id: id));
        break;
      case 'clear':
        _consoleLines.value = [];
        break;
      case 'exit':
        _appendLine('[EXITING...]');
        break;
      default:
        _appendLine('[UNKNOWN COMMAND]: $command');
    }
  }

  void _onSubmitted(String input) {
    if (input.trim().isEmpty) return;
    _appendLine('vault> $input');
    _commandController.clear();
    _handleCommand(input);
  }

  List<String> _formatEntry({
    int vaultEntriesLength = 1,
    int currentIndex = 0,
    required VaultEntryEntity entry,
  }) {
    return [
      if (vaultEntriesLength > 1 && currentIndex == 0) '[',
      ...(vaultEntriesLength > 1
          ? [
              '  {',
              '   id: ${entry.id},',
              '   title: ${entry.title},',
              if (entry.username != null && entry.username!.isNotEmpty)
                '   username: ${entry.username},',
              if (entry.email != null && entry.email!.isNotEmpty)
                '   email: ${entry.email},',
              if (entry.contactNo != null && entry.contactNo!.isNotEmpty)
                '   contactNo: ${entry.contactNo},',
              if (entry.notes != null && entry.notes!.isNotEmpty)
                '   notes: ${entry.notes},',
              '   password: ${entry.password},',
              '   created_at: ${entry.createdAt},',
              if (entry.updatedAt != null) '   updated_at: ${entry.updatedAt},',
              '  },',
            ]
          : [
              '{',
              ' id: ${entry.id},',
              ' title: ${entry.title},',
              if (entry.username != null && entry.username!.isNotEmpty)
                ' username: ${entry.username},',
              if (entry.email != null && entry.email!.isNotEmpty)
                ' email: ${entry.email},',
              if (entry.contactNo != null && entry.contactNo!.isNotEmpty)
                ' contactNo: ${entry.contactNo},',
              if (entry.notes != null && entry.notes!.isNotEmpty)
                ' notes: ${entry.notes},',
              ' password: ${entry.password},',
              ' created_at: ${entry.createdAt},',
              if (entry.updatedAt != null) ' updated_at: ${entry.updatedAt},',
              '}',
            ]),
      if (vaultEntriesLength > 1 && currentIndex == vaultEntriesLength - 1) ']',
    ];
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
              child: BlocListener<VaultBloc, VaultState>(
                listener: (context, state) {
                  if (state is LoadingVault) {
                    _appendLine('[PROCESSING REQUEST...]');
                  } else if (state is LoadedVault) {
                    final vaultEntries = state.vaultEntryEntities;
                    final vaultEntriesLength = vaultEntries.length;
                    final fetchedCountMessage = vaultEntriesLength > 0
                        ? '[FETCHED $vaultEntriesLength ${vaultEntriesLength > 1 ? 'ENTRIES' : 'ENTRY'}]'
                        : '[NO VAULT ENTRIES]';

                    _appendLine(fetchedCountMessage);

                    for (int i = 0; i < vaultEntriesLength; i++) {
                      final entry = vaultEntries[i];

                      _appendLines(
                        _formatEntry(
                          vaultEntriesLength: vaultEntriesLength,
                          currentIndex: i,
                          entry: entry,
                        ),
                      );
                    }
                  } else if (state is EntryLoaded) {
                    if (state.vaultEntryEntity != null) {
                      _appendLines(
                        _formatEntry(entry: state.vaultEntryEntity!),
                      );
                    } else {
                      _appendLine('[ERROR]: ENTRY NOT FOUND');
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
