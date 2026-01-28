class CommandSuggester {
  String? suggest(String input, List<String> options) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    String? best;
    var bestScore = 3; // only suggest if distance <= 2

    for (final option in options) {
      final score = _levenshtein(normalized, option.toLowerCase());
      if (score < bestScore) {
        bestScore = score;
        best = option;
      }
    }

    return best;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final costs = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      var previous = i - 1;
      costs[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final temp = costs[j];
        final insert = costs[j] + 1;
        final delete = costs[j - 1] + 1;
        final replace = previous + (a[i - 1] == b[j - 1] ? 0 : 1);
        costs[j] = _min(insert, _min(delete, replace));
        previous = temp;
      }
    }
    return costs[b.length];
  }

  int _min(int a, int b) => a < b ? a : b;
}
