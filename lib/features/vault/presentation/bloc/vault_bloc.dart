import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/no_params.dart';
import '../../../../core/utils/emit_and_refresh.dart';
import '../../../../core/utils/emit_result.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entity/vault_entry_entity.dart';
import '../../domain/usecases/add_vault_entry.dart';
import '../../domain/usecases/delete_all_entries.dart';
import '../../domain/usecases/delete_vault_entry.dart';
import '../../domain/usecases/get_all_vault_entries.dart';
import '../../domain/usecases/get_vault_entries_by_title.dart';
import '../../domain/usecases/get_vault_entry_by_id.dart';
import '../../domain/usecases/update_vault_entry.dart';

part 'vault_event.dart';
part 'vault_state.dart';

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  VaultBloc({
    required AddVaultEntry addVaultEntry,
    required GetAllVaultEntries getAllVaultEntries,
    required GetVaultEntryById getVaultEntryById,
    required GetVaultEntriesByTitle getVaultEntriesByTitle,
    required UpdateVaultEntry updateVaultEntry,
    required DeleteVaultEntry deleteVaultEntry,
    required DeleteAllEntries deleteAllEntries,
  }) : _addVaultEntry = addVaultEntry,
       _getAllVaultEntries = getAllVaultEntries,
       _getVaultEntryById = getVaultEntryById,
       _getVaultEntriesByTitle = getVaultEntriesByTitle,
       _updateVaultEntry = updateVaultEntry,
       _deleteVaultEntry = deleteVaultEntry,
       _deleteAllEntries = deleteAllEntries,
       super(InitialVault()) {
    on<AddVaultEntryEvent>(_onAddVaultEntry);
    on<GetAllVaultEntriesEvent>(_onGetAllVaultEntries);
    on<GetVaultEntryByIdEvent>(_onGetVaultEntryById);
    on<GetVaultEntriesByTitleEvent>(_onGetVaultEntriesByTitle);
    on<UpdateVaultEntryEvent>(_onUpdateVaultEntry);
    on<DeleteVaultEntryEvent>(_onDeleteVaultEntry);
    on<DeleteAllEntriesEvent>(_onDeleteVaultEntries);
  }

  final AddVaultEntry _addVaultEntry;
  final GetAllVaultEntries _getAllVaultEntries;
  final GetVaultEntryById _getVaultEntryById;
  final GetVaultEntriesByTitle _getVaultEntriesByTitle;
  final UpdateVaultEntry _updateVaultEntry;
  final DeleteVaultEntry _deleteVaultEntry;
  final DeleteAllEntries _deleteAllEntries;

  void _onAddVaultEntry(
    AddVaultEntryEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(LoadingVault());

    final vaultEntryEntity = VaultEntryEntity(
      id: IdGenerator.newId(),
      title: event.title,
      password: event.password,
      username: event.username,
      email: event.email,
      contactNo: event.contactNo,
      notes: event.notes,
      createdAt: DateTime.now(),
    );

    await emitAndRefresh<VaultState, VaultEntryEntity, VaultEntryEntity>(
      emit,
      _addVaultEntry(vaultEntryEntity),
      () => _getAllVaultEntries(NoParams()),
      (l) => ErrorVault(message: l),
      (r) => LoadedVault(vaultEntryEntities: r),
    );
  }

  void _onGetAllVaultEntries(
    GetAllVaultEntriesEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(LoadingVault());

    await emitResult<VaultState, List<VaultEntryEntity>>(
      emit,
      _getAllVaultEntries(NoParams()),
      onError: (l) => ErrorVault(message: l),
      onSuccess: (r) => LoadedVault(vaultEntryEntities: r),
    );
  }

  void _onGetVaultEntryById(
    GetVaultEntryByIdEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(LoadingVault());

    await emitResult<VaultState, VaultEntryEntity?>(
      emit,
      _getVaultEntryById(event.id),
      onError: (l) => ErrorVault(message: l),
      onSuccess: (r) => EntryLoaded(vaultEntryEntity: r),
    );
  }

  void _onGetVaultEntriesByTitle(
    GetVaultEntriesByTitleEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(LoadingVault());

    await emitResult<VaultState, List<VaultEntryEntity>>(
      emit,
      _getVaultEntriesByTitle(event.title),
      onError: (l) => ErrorVault(message: l),
      onSuccess: (r) => LoadedVault(vaultEntryEntities: r),
    );
  }

  void _onUpdateVaultEntry(
    UpdateVaultEntryEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(LoadingVault());

    final getExistingEntryResult = await _getVaultEntryById(event.id);

    await getExistingEntryResult.fold(
      (l) async => emit(ErrorVault(message: l.message)),
      (r) async {
        final existingEntry = r;
        if (existingEntry == null) {
          emit(const ErrorVault(message: '[ERROR]: ENTRY NOT FOUND'));
          return;
        }

        final updatedEntry = VaultEntryEntity(
          id: existingEntry.id,
          title: event.title ?? existingEntry.title,
          password: event.password ?? existingEntry.password,
          username: event.username ?? existingEntry.username,
          email: event.email ?? existingEntry.email,
          contactNo: event.contactNo ?? existingEntry.contactNo,
          notes: event.notes ?? existingEntry.notes,
          createdAt: existingEntry.createdAt,
          updatedAt: DateTime.now(),
        );

        await emitAndRefresh(
          emit,
          _updateVaultEntry(updatedEntry),
          () => _getAllVaultEntries(NoParams()),
          (l) => ErrorVault(message: l),
          (r) => LoadedVault(vaultEntryEntities: r),
        );
      },
    );
  }

  void _onDeleteVaultEntry(
    DeleteVaultEntryEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(LoadingVault());

    await emitAndRefresh<VaultState, bool, VaultEntryEntity>(
      emit,
      _deleteVaultEntry(event.id),
      () => _getAllVaultEntries(NoParams()),
      (l) => ErrorVault(message: l),
      (r) => LoadedVault(vaultEntryEntities: r),
    );
  }

  void _onDeleteVaultEntries(
    DeleteAllEntriesEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(LoadingVault());

    await emitResult(
      emit,
      _deleteAllEntries(NoParams()),
      onError: (l) => ErrorVault(message: l),
      onSuccess: (r) => ClearedVault(),
    );
  }
}
