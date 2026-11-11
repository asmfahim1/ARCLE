import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

/// A reusable card widget for displaying user information.
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
    );
  }
}
