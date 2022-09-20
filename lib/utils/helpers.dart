import 'package:intl/intl.dart';

sum(list) {
  num total = 0;
  for (var value in list) {
    total += value;
  }
  return total;
}

mostPopularValue(list) {
// Count occurrences of each item
  final folded = list.fold({}, (acc, curr) {
    acc[curr] = (acc[curr] ?? 0) + 1;
    return acc;
  }) as Map<dynamic, dynamic>;

  // Sort the keys (your values) by its occurrences
  final sortedKeys = folded.keys.toList()
    ..sort((a, b) => folded[b].compareTo(folded[a]));

  return sortedKeys.first;
}

String timestampToString(int value, format) {
  return DateFormat(format).format(DateTime.fromMillisecondsSinceEpoch(value));
}
