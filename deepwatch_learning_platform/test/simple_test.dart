import 'package:flutter_test/flutter_test.dart';
import 'package:deepwatch_learning_platform/services/database_helper.dart';

void main() {
  test('simple database helper test', () {
    final helper = DatabaseHelper();
    expect(helper, isNotNull);
  });
}