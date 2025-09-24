Map<String, String?> flagParser(List<String> args) {
  final result = <String, String?>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('-')) {
      final key = arg.substring(1);

      // For -n flag, capture all words or until next flag
      if (key == 'q' || key == 'a' || key == 'n') {
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