String? checkPassword(String password) {
  if (password.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }
  final RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$');
  final RegExpMatch? match = regex.firstMatch(password);
  if (match == null) {
    return 'La contraseña debe tener al menos un número, una letra mayúscula, una letra minúscula, un caracter especial y no debe tener números ni letras consecutivas';
  }
  return null;
}
