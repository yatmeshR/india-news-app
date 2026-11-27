import 'strings_data.dart';

/// Looks up UI copy from the design handoff. Falls back to English, then the key.
class AppStrings {
  const AppStrings(this.languageCode);
  final String languageCode;

  bool get isHindi => languageCode == 'hi';
  bool get isMarathi => languageCode == 'mr';

  String call(String key) =>
      kStrings[languageCode]?[key] ?? kStrings['en']![key] ?? key;

  /// "2h ago" for fresh stories, "29 Jun 2024" otherwise.
  String relative(DateTime time, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final d = n.difference(time);
    if (!d.isNegative && d.inHours < 24) {
      if (d.inMinutes < 1) return isHindi ? 'अभी' : (isMarathi ? 'आत्ताच' : 'Just now');
      if (d.inMinutes < 60) {
        return isHindi
            ? '${d.inMinutes} मिनट पहले'
            : isMarathi
                ? '${d.inMinutes} मिनिटांपूर्वी'
                : '${d.inMinutes}m ago';
      }
      return isHindi
          ? '${d.inHours} घंटे पहले'
          : isMarathi
              ? '${d.inHours} तासांपूर्वी'
              : '${d.inHours}h ago';
    }
    final t = time.toLocal();
    final m = (isHindi ? _monthsHi : isMarathi ? _monthsMr : _monthsEn)[t.month - 1];
    return '${t.day} $m ${t.year}';
  }
}

const _monthsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _monthsHi = [
  'जन॰', 'फ़र॰', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुल॰', 'अग॰', 'सित॰', 'अक्टू॰', 'नव॰', 'दिस॰',
];
const _monthsMr = [
  'जाने', 'फेब्रु', 'मार्च', 'एप्रिल', 'मे', 'जून', 'जुलै', 'ऑग', 'सप्टें', 'ऑक्टो', 'नोव्हें', 'डिसें',
];
