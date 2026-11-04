import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_05_api/main.dart';

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    // Configurar un tamaño de pantalla para evitar errores de overflow
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Cargar la app (usando la clase MenuPage que es nuestra pantalla principal)
    await tester.pumpWidget(const MaterialApp(home: MenuPage()));

    // Verificar que el menú principal se dibuje correctamente
    expect(find.text('Práctica 05 - Menú'), findsOneWidget);
    expect(find.text('Usuarios (Ejemplo Guiado)'), findsOneWidget);
    expect(find.text('Posts (Ejercicio Evaluable)'), findsOneWidget);
  });
}