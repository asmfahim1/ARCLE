import 'package:arcle/src/state_management.dart';
import 'package:test/test.dart';

void main() {
  test('StateManagement.fromInput supports Riverpod only', () {
    expect(StateManagement.fromInput('riverpod'), StateManagement.riverpod);
    expect(StateManagement.fromInput('bloc'), isNull);
    expect(StateManagement.fromInput('getx'), isNull);
  });
}
