import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// One `AppDatabase` (and its underlying sqlite connection) for the whole
/// app session — deliberately not `autoDispose`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
