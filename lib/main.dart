import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await Supabase.initialize(
    url: 'https://gvnxpoxpekfvegactxcg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2bnhwb3hwZWtmdmVnYWN0eGNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyODY1NjksImV4cCI6MjA3OTg2MjU2OX0.q6o771brWyj9Sdvuc9ZRcYrwmPRVo7w8HGlITfWKhz4',
  );

  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
