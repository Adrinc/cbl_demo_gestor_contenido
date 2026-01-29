int? extractNumberFromText(String text) {
  // Expresión regular para encontrar el primer número en el texto
  RegExp regExp = RegExp(r'\d+');
  Match? match = regExp.firstMatch(text);

  // Si se encuentra un número, devolverlo como un entero
  if (match != null) {
    return int.tryParse(match.group(0) ?? '');
  }

  // Si no se encuentra ningún número, devolver null
  return null;
}
