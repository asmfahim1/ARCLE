import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_state.dart';
import '../widgets/payment_card.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('payment_title'))),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          switch (state.status) {
            case PaymentStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case PaymentStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case PaymentStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    PaymentCard(entity: state.items[index]),
              );
            case PaymentStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
