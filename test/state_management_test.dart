import 'package:arcle/src/state_management.dart';
import 'package:test/test.dart';

void main() {
  test('StateManagement.fromInput supports numeric and name', () {
    expect(StateManagement.fromInput('1'), StateManagement.bloc);
    expect(StateManagement.fromInput('2'), StateManagement.getx);
    expect(StateManagement.fromInput('3'), StateManagement.riverpod);
    expect(StateManagement.fromInput('bloc'), StateManagement.bloc);
  });
}
