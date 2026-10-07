import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/demo/data/models/user_model.dart';

void main() {
  test('UserModel.fromJson parses values', () {
    final model = UserModel.fromJson({
      'id': 1,
      'name': 'Jane',
      'email': 'jane@example.com',
    });
    expect(model.id, 1);
    expect(model.name, 'Jane');
    expect(model.email, 'jane@example.com');
  });
}
