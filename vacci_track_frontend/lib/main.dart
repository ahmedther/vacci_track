import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/components/home.dart';

void main() {
  runApp(
    const ProviderScope(
      child: Home(),
    ),
  );
}
