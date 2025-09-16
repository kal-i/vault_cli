import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'core/services/crypto_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/utils/vault_entry_crypto_mapper.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/initialize_vault.dart';
import 'features/auth/domain/usecases/unlock_vault.dart';
import 'features/auth/presentation/bloc/vault_auth_bloc.dart';
import 'features/password_vault_console/data/data_sources/local/db_utils.dart';
import 'features/password_vault_console/data/data_sources/local/vault_database.dart';
import 'features/password_vault_console/data/data_sources/local/vault_local_data_source.dart';
import 'features/password_vault_console/data/data_sources/local/vault_local_data_source_impl.dart';
import 'features/password_vault_console/data/repository/vault_repository_impl.dart';
import 'features/password_vault_console/domain/repository/vault_repository.dart';
import 'features/password_vault_console/domain/usecases/add_vault_entry.dart';
import 'features/password_vault_console/domain/usecases/delete_vault_entry.dart';
import 'features/password_vault_console/domain/usecases/get_all_vault_entries.dart';
import 'features/password_vault_console/domain/usecases/get_vault_entries_by_title.dart';
import 'features/password_vault_console/domain/usecases/get_vault_entry_by_id.dart';
import 'features/password_vault_console/domain/usecases/update_vault_entry.dart';
import 'features/password_vault_console/presentation/bloc/vault_bloc.dart';

part 'init_dependencies.main.dart';