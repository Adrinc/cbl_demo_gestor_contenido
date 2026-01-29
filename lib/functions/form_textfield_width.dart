double formTextFieldWidth(double anchoPantalla, double anchoMin, double anchoMax, double valorMin, double valorMax) {
  // Fórmula de interpolación lineal para calcular tamaños adaptativos.
  return valorMin + (valorMax - valorMin) * ((anchoPantalla - anchoMin) / (anchoMax - anchoMin));
}
