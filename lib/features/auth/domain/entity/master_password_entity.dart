class MasterPasswordEntity {
  const MasterPasswordEntity({required this.password, required this.recoveryQuestion, required this.recoveryAnswer,});

  final String password;
  final String recoveryQuestion;
  final String recoveryAnswer;
}