import 'package:flutter/material.dart';
import 'package:medication_structure/home.dart';
import 'package:medication_structure/provider/provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Sample App';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Mqttprovider())
        ],
        child: MaterialApp(
          title: _title,
          home: Homepage(),
        ));
  }
}
