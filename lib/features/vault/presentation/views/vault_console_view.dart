import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_path.dart';
import '../../../../core/utils/flag_parser.dart';
import '../../../auth/presentation/views/vault_auth_cli_view.dart';
import '../../domain/entity/vault_entry_entity.dart';
import '../bloc/vault_bloc.dart';
import '../../../../core/common/components/console_text.dart';
import '../../../../core/common/components/console_text_field.dart';

class VaultConsoleView extends StatefulWidget {
  const VaultConsoleView({super.key});

  @override
  State<VaultConsoleView> createState() => _VaultConsoleViewState();
}

class _VaultConsoleViewState extends State<VaultConsoleView> {
  final ValueNotifier<List<String>> _consoleLines = ValueNotifier(
    _initConsoleLines(),
  );
  final ValueNotifier<String> _contextPath = ValueNotifier(ContextPath.vault);

  final _commandController = TextEditingController();
  final _scrollController = ScrollController();

  static List<String> _initConsoleLines() => [
    'vault_cli v1.0',
    '',
    'Welcome to the main console.',
    'Current directory: vault',
    'Type `help` to see available commands.',
  ];

  static const _commandUsages = {
    'add':
        ' add -t <title> -p <password> [-u <username>] [-e <email>] [-c <contact>] [-n <notes>]',
    'list': '''
 list all          - Show all entries.
 list -t <title>   - Show filtered entries by title.
          ''',
    'get': '  get -i <id>',
    'update':
        ' update -i <id> [-t <title>] [-p <password>] [-u <username>] [-e <email>] [-c <contact>] [-n <notes>]',
    'delete': '  delete -i <id>',
  };

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
        '[ERROR]: Missing required ${hasMoreThanOneFlag ? 'flags' : 'flag'}.',
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
        _printHelp();
        break;
      case 'add':
        _handleAdd(args, vaultBloc);
        break;
      case 'list':
        _handleList(args, vaultBloc);
        break;
      case 'get':
        _handleGet(args, vaultBloc);
        break;
      case 'update':
        _handleUpdate(args, vaultBloc);
        break;
      case 'delete':
        _handleDelete(args, vaultBloc);
        break;
      case 'lock':
        _lock();
        break;
      case 'clear':
        _consoleLines.value = _initConsoleLines();
        break;
      case 'exit':
        _exit();
        break;
      default:
        _appendLine('[UNKNOWN COMMAND]: $command.');
    }
  }

  void _printHelp() {
    _appendLines([
      '',
      'Available Commands:',
      ' help      - See available commands.',
      ' add       - Add a new entry.',
      ' list      - Show stored entries.',
      ' get       - Retrieve an entry.',
      ' update    - Update an existing entry.',
      ' delete    - Delete entries.',
      ' lock      - Lock the vault.',
      ' clear     - Clear the console.',
      ' exit      - Exit the app.',
      '',
      'Tip: Type command name + Enter to execute.',
    ]);
  }

  void _handleAdd(List<String> args, VaultBloc vaultBloc) {
    final usage = _commandUsages['add']!;
    if (args.isEmpty) return _printUsage(usage: usage);

    final flags = flagParser(args);
    final title = flags['t'];
    final password = flags['p'];

    if (title == null || password == null) {
      return _printUsage(usage: usage, isError: true);
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
  }

  void _handleList(List<String> args, VaultBloc vaultBloc) {
    final usage = _commandUsages['list']!;

    if (args.isEmpty) return _printUsage(usage: usage);

    final subCommand = args.first;

    switch (subCommand) {
      case 'all':
        vaultBloc.add(GetAllVaultEntriesEvent());
        break;
      case '-t':
        if (args.length < 2) {
          return _printUsage(
            usage: '  list -t <title>',
            hasMoreThanOneFlag: false,
            isError: true,
          );
        }
        final title = args[1];
        vaultBloc.add(GetVaultEntriesByTitleEvent(title: title));
        break;
      default:
        _printUsage(usage: usage, isError: true);
        break;
    }
  }

  void _handleGet(List<String> args, VaultBloc vaultBloc) {
    final usage = _commandUsages['get']!;
    if (args.isEmpty) return _printUsage(usage: usage);

    final flag = flagParser(args);
    final id = flag['i'];

    if (id == null) {
      return _printUsage(
        usage: usage,
        hasMoreThanOneFlag: false,
        isError: true,
      );
    }

    vaultBloc.add(GetVaultEntryByIdEvent(id: id));
  }

  void _handleUpdate(List<String> args, VaultBloc vaultBloc) {
    final usage = _commandUsages['update']!;
    if (args.isEmpty) return _printUsage(usage: usage);

    final flags = flagParser(args);
    final id = flags['i'];

    if (id == null) {
      return _printUsage(usage: usage, isError: true);
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
  }

  void _handleDelete(List<String> args, VaultBloc vaultBloc) {
    final usage = _commandUsages['delete']!;

    if (args.isEmpty) return _printUsage(usage: usage);

    final flags = flagParser(args);
    final id = flags['i'];

    if (id == null) {
      return _printUsage(
        usage: '  delete -i <id>',
        hasMoreThanOneFlag: false,
        isError: true,
      );
    }
    vaultBloc.add(DeleteVaultEntryEvent(id: id));
  }

  void _lock() async {
    _appendLine('[LOCK]: App will be lock in 3 seconds...');
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VaultAuthCliView()),
    );
  }

  void _exit() async {
    _appendLine('[EXIT]: App will close in 3 seconds...');
    await Future.delayed(const Duration(seconds: 3));
    SystemNavigator.pop();
  }

  void _onSubmitted(String input) {
    if (input.trim().isEmpty) return;
    _appendLine('${_contextPath.value} $input');
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
                      _appendLines([
                        '[FETCHED ENTRY]',
                        ..._formatEntry(entry: state.vaultEntryEntity!),
                      ]);
                    } else {
                      _appendLine('[ERROR]: ENTRY NOT FOUND.');
                    }
                  } else if (state is ErrorVault) {
                    _appendLine('[ERROR]: ${state.message}.');
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
