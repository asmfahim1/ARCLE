import 'package:arcle/src/state_management.dart';
import 'package:test/test.dart';

void main() {
  group('StateManagement', () {
    test('fromInput supports all state management options', () {
      expect(StateManagement.fromInput('riverpod'), StateManagement.riverpod);
      expect(StateManagement.fromInput('bloc'), StateManagement.bloc);
      expect(StateManagement.fromInput('getx'), StateManagement.getx);
    });

    test('fromInput is case insensitive', () {
      expect(StateManagement.fromInput('RIVERPOD'), StateManagement.riverpod);
      expect(StateManagement.fromInput('BLoC'), StateManagement.bloc);
      expect(StateManagement.fromInput('GETX'), StateManagement.getx);
    });

    test('fromInput returns null for invalid input', () {
      expect(StateManagement.fromInput('invalid'), isNull);
      expect(StateManagement.fromInput(''), isNull);
    });

    test('fromOption returns correct state for valid options', () {
      expect(StateManagement.fromOption(1), StateManagement.bloc);
      expect(StateManagement.fromOption(2), StateManagement.getx);
      expect(StateManagement.fromOption(3), StateManagement.riverpod);
    });

    test('fromOption returns null for invalid options', () {
      expect(StateManagement.fromOption(0), isNull);
      expect(StateManagement.fromOption(4), isNull);
      expect(StateManagement.fromOption(-1), isNull);
    });

    test('each state has correct id and label', () {
      expect(StateManagement.bloc.id, 'bloc');
      expect(StateManagement.bloc.label, 'BLoC');
      expect(StateManagement.getx.id, 'getx');
      expect(StateManagement.getx.label, 'GetX');
      expect(StateManagement.riverpod.id, 'riverpod');
      expect(StateManagement.riverpod.label, 'Riverpod');
    });

    test('option property returns 1-based index', () {
      expect(StateManagement.bloc.option, 1);
      expect(StateManagement.getx.option, 2);
      expect(StateManagement.riverpod.option, 3);
    });
  });
}
