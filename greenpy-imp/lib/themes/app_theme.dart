import 'package:flutter/material.dart';

class AppColors {
  static const primaryGreen = Color(0xFF4CAF50); // verde principal
  static const darkGreen = Color(0xFF388E3C);    // verde escuro
  static const lightGreen = Color(0xFFC8E6C9);   // verde claro
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Habilita o Material Design 3 (Material You)
    fontFamily: 'Poppins', // Fonte padrão da aplicação

    // Esquema de cores baseado na cor semente verde
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen, // Verde principal
      brightness: Brightness.light, // Tema claro
    ),

    // Tema padrão para campos de entrada (TextField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.withOpacity(0.1), // Fundo sutil
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
    ),

    // Tema da barra de navegação inferior
    navigationBarTheme: NavigationBarThemeData(
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9), // Indicador arredondado
      ),
      indicatorColor: AppColors.primaryGreen, // Cor do indicador
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    ),
  );
}