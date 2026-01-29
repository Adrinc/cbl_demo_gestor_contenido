String moneyFormat3Decimals(double x) {
  List<String> parts = x.toString().split('.');
  RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');

  parts[0] = parts[0].replaceAll(re, ',');
  if (parts.length == 1) {
    parts.add('00');
  } else {
    parts[1] = parts[1].padRight(3, '0').substring(0, 3);
  }
  return parts.join('.');
}
