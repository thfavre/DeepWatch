import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('simple database test', () async {
    // Simple test to verify sqflite_ffi works
    final db = await openDatabase(':memory:');
    await db.execute('CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)');
    await db.insert('test', {'name': 'test'});
    final result = await db.query('test');
    expect(result.length, equals(1));
    expect(result.first['name'], equals('test'));
    await db.close();
  });
}