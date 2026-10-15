String removeVietnameseTones(String str) {
  var result = str;
  result = result.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
  result = result.replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A');
  result = result.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
  result = result.replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E');
  result = result.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
  result = result.replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I');
  result = result.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
  result = result.replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O');
  result = result.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
  result = result.replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U');
  result = result.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
  result = result.replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y');
  result = result.replaceAll(RegExp(r'[đ]'), 'd');
  result = result.replaceAll(RegExp(r'[Đ]'), 'D');
  return result;
}
