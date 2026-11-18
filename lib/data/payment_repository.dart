import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PayMethod { orangeMoney, mtnMomo, card }

/// Paiement. Le vrai Mobile Money viendra plus tard derrière cette interface.
abstract class PaymentRepository {
  Future<bool> pay({required PayMethod method, required int amount, String? phone});
}

class MockPaymentRepository implements PaymentRepository {
  @override
  Future<bool> pay({required PayMethod method, required int amount, String? phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return true;
  }
}

final paymentRepositoryProvider =
    Provider<PaymentRepository>((_) => MockPaymentRepository());
