import 'package:flutter/material.dart';
import 'package:jomjalan/providers/gamification_provider.dart';
import 'package:jomjalan/providers/itinerary_provider.dart';
import 'package:jomjalan/screens/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- JomJalan Color Palette ---
// Your specified green
const Color primaryGreen = Color.fromARGB(255, 0, 189, 108);
const Color backgroundColor = Color.fromRGBO(31, 31, 31, 1);
const Color secondaryBackgroundColor = Color.fromRGBO(50, 47, 46, 1);
const Color accentColor = Color.fromRGBO(8, 192, 104, 1);
const Color textColor = Color.fromARGB(255, 253, 253, 253);
const Color subTextColor = Color.fromARGB(255, 215, 215, 215);

// We need to create a "MaterialColor" swatch for the theme.
// This is a standard Flutter way to use a custom color.
const MaterialColor primaryGreenSwatch = MaterialColor(
  0xFF00bd6c, // The main 500 shade's hex value
  <int, Color>{
    50: Color(0xFFE0F7F1), // Very light green
    100: Color(0xFFB3EBDC), // Light green
    200: Color(0xFF80DDC5), // Light-mid green
    300: Color(0xFF4DCFAC), // Mid green
    400: Color(0xFF26C69A), // Strong green
    500: Color(0xFF00bd6c), // <-- Your new primary color
    600: Color(0xFF00A861), // Darker green
    700: Color(0xFF009355), // Dark green
    800: Color(0xFF007E4A), // Very dark green
    900: Color(0xFF00693E), // Deep dark green
  },
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 Load your .env file before runApp()
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItineraryProvider()),
        ChangeNotifierProvider(create: (context) => GamificationProvider()),
      ],
      child: const JomJalanApp(),
    ),
  );
}

class JomJalanApp extends StatelessWidget {
  const JomJalanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JomJalan',
      theme: ThemeData(
        primarySwatch: primaryGreenSwatch,
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Inter', // You can add this font to pubspec.yaml
        appBarTheme: const AppBarTheme(
          elevation: 1,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          titleTextStyle: TextStyle(
            color: primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: backgroundColor,
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 2,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // Start the app at the Welcome Page
      home: WelcomePage(),
    );
  }
}
