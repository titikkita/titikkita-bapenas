import 'package:flutter/material.dart';
import 'package:titikkita/router.dart' as router;
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/state/polyline_provider.dart';
import 'package:titikkita/state/principal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // SharedPreferences.setMockInitialValues({});
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<LocalProvider>(
          create: (_) => LocalProvider(),
        ),
        provider.ChangeNotifierProvider<IndividualProvider>(
          create: (_) => IndividualProvider(),
        ),
        provider.ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
        provider.ChangeNotifierProvider<PolylineProvider>(
          create: (_) => PolylineProvider(),
        ),
        provider.ChangeNotifierProvider<PrincipalProvider>(
          create: (_) => PrincipalProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Named Routing',
        onGenerateRoute: router.generateRoute,
        initialRoute: '/login',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
