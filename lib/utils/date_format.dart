String? formatDateToIso(String? text) {
  if (text == null || text.isEmpty) return null;

  final parts = text.split('/');
  if (parts.length != 3) return null;

  try {
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final date = DateTime(year, month, day);
    return date.toIso8601String().split('T')[0]; // yyyy-MM-dd
  } catch (e) {
    return null;
  }
}