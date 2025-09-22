part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  _registerCoreDependencies();
  _registerServicesDependencies();
  _registerStartupDependencies();
  await _registerVaultLocalDependencies();
  _registerVaultAuthDependencies();
}

void _registerCoreDependencies() {}

void _registerServicesDependencies() {
  serviceLocator
    ..registerLazySingleton<SecureStorageService>(() => SecureStorageService())
    ..registerLazySingleton<CryptoService>(() => CryptoService());
}

void _registerStartupDependencies() {
  _registerFactory<StartupBloc>(
    () => StartupBloc(secureStorageService: serviceLocator()),
  );
}

Future<void> _registerVaultLocalDependencies() async {
  final db = await VaultDatabase.create();

  if (kDebugMode && kResetVaultOnStartup) {
    await clearVaultTable(db);

    final storage = serviceLocator<SecureStorageService>();
    await storage.clear();
  }

  serviceLocator
    ..registerLazySingleton<VaultDatabase>(() => db)
    ..registerLazySingleton<VaultLocalDataSource>(
      () => VaultLocalDataSourceImpl(db: serviceLocator()),
    );
}

void _registerVaultAuthDependencies() {
  serviceLocator
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        secureStorageService: serviceLocator(),
        cryptoService: serviceLocator(),
        vaultLocalDataSource: serviceLocator(),
      ),
    )
    ..registerLazySingleton<InitializeVault>(
      () => InitializeVault(authRepository: serviceLocator()),
    )
    ..registerLazySingleton<UnlockVault>(
      () => UnlockVault(authRepository: serviceLocator()),
    )
    ..registerLazySingleton<RetrieveRecoveryQuestion>(
      () => RetrieveRecoveryQuestion(authRepository: serviceLocator()),
    )
    ..registerLazySingleton<VerifyRecoveryAnswer>(
      () => VerifyRecoveryAnswer(authRepository: serviceLocator()),
    )
    ..registerLazySingleton<SetupNewMasterPassword>(
      () => SetupNewMasterPassword(authRepository: serviceLocator()),
    )
    ..registerFactory<VaultAuthBloc>(
      () => VaultAuthBloc(
        initializeVault: serviceLocator(),
        unlockVault: serviceLocator(),
        retrieveRecoveryQuestion: serviceLocator(),
        verifyRecoveryAnswer: serviceLocator(),
        setupNewMasterPassword: serviceLocator(),
      ),
    );
}

void setupVaultRepositoryAndBloc(SecretKey secretKey) {
  // Always reset these dependencies, especially since it relies on a [SecretKey].
  resetVaultDependencies();
  _registerLazySingleton<VaultEntryCryptoMapper>(
    () => VaultEntryCryptoMapper(
      cryptoService: serviceLocator(),
      secretKey: secretKey,
    ),
  );
  _registerLazySingleton<VaultRepository>(
    () => VaultRepositoryImpl(
      vaultLocalDataSource: serviceLocator(),
      vaultEntryCryptoMapper: serviceLocator(),
    ),
  );
  _registerLazySingleton<AddVaultEntry>(
    () => AddVaultEntry(vaultRepository: serviceLocator()),
  );
  _registerLazySingleton<GetAllVaultEntries>(
    () => GetAllVaultEntries(vaultRepository: serviceLocator()),
  );
  _registerLazySingleton<GetVaultEntryById>(
    () => GetVaultEntryById(vaultRepository: serviceLocator()),
  );
  _registerLazySingleton<GetVaultEntriesByTitle>(
    () => GetVaultEntriesByTitle(vaultRepository: serviceLocator()),
  );
  _registerLazySingleton<UpdateVaultEntry>(
    () => UpdateVaultEntry(vaultRepository: serviceLocator()),
  );
  _registerLazySingleton<DeleteVaultEntry>(
    () => DeleteVaultEntry(vaultRepository: serviceLocator()),
  );
  _registerFactory<VaultBloc>(
    () => VaultBloc(
      addVaultEntry: serviceLocator(),
      getAllVaultEntries: serviceLocator(),
      getVaultEntryById: serviceLocator(),
      getVaultEntriesByTitle: serviceLocator(),
      updateVaultEntry: serviceLocator(),
      deleteVaultEntry: serviceLocator(),
    ),
  );
}

/// Removes all vault-related dependencies from the service locator.
/// Call when user logs out or reset the vault.
void resetVaultDependencies() {
  _safeUnregister<VaultEntryCryptoMapper>();
  _safeUnregister<VaultRepository>();
  _safeUnregister<AddVaultEntry>();
  _safeUnregister<GetAllVaultEntries>();
  _safeUnregister<GetVaultEntryById>();
  _safeUnregister<GetVaultEntriesByTitle>();
  _safeUnregister<UpdateVaultEntry>();
  _safeUnregister<DeleteVaultEntry>();
  _safeUnregister<VaultBloc>();
}

/// Helper function to safely register a lazy singleton dependency if it's not registered yet.
void _registerLazySingleton<T extends Object>(T Function() factory) {
  if (!serviceLocator.isRegistered<T>()) {
    serviceLocator.registerLazySingleton<T>(factory);
  }
}

/// Helper function to safely register a factory dependency if it's not registered yet.
void _registerFactory<T extends Object>(T Function() factory) {
  if (!serviceLocator.isRegistered<T>()) {
    serviceLocator.registerFactory<T>(factory);
  }
}

/// Helper function to to safely unregister a dependency in service locator.
void _safeUnregister<T extends Object>() {
  if (serviceLocator.isRegistered<T>()) {
    serviceLocator.unregister<T>();
  }
}
