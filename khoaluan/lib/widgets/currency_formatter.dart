import '../services/locale_service.dart';

String formatVND(double amount, {String? languageCode}) {
  final code = languageCode ?? LocaleService.locale.value.languageCode;
  final String str = amount.toStringAsFixed(0);
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final separator = code == 'en' ? ',' : '.';
  final formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]}$separator');
  return code == 'en' ? '₫$formatted' : '$formatted đ';
}
