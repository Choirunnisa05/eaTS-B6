import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'eats_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (url.isEmpty || key.isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Isi SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY saat menjalankan Flutter.',
            ),
          ),
        ),
      ),
    );
    return;
  }
  final redirectError = kIsWeb ? authRedirectError(Uri.base) : null;
  await Supabase.initialize(url: url, publishableKey: key);
  runApp(EatsAuthApp(redirectError: redirectError));
}
