import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/api_providers.dart';
import 'models.dart';

enum PayMethod { orangeMoney, mtnMomo, card }

extension on PayMethod {
  String get wire => switch (this) {
        PayMethod.orangeMoney => 'orange_money',
        PayMethod.mtnMomo => 'mtn_momo',
        PayMethod.card => 'card',
      };
}

/// Réservation + paiement d'un rendez-vous.
class BookingPayment {
  const BookingPayment({
    required this.dietitianId,
    required this.day,
    required this.time,
    required this.mode,
    required this.method,
    this.phone,
  });
  final String dietitianId;
  final DateTime day;
  final String time; // « 10:30 »
  final ConsultMode mode;
  final PayMethod method;
  final String? phone;
}

/// Réserve le créneau et enregistre le paiement. Lève [ApiException] en cas d'échec
/// (409 = créneau pris entre-temps). Le vrai Mobile Money viendra derrière cette interface.
abstract class PaymentRepository {
  Future<void> payAndBook(BookingPayment booking);
}

class MockPaymentRepository implements PaymentRepository {
  @override
  Future<void> payAndBook(BookingPayment booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }
}

class ApiPaymentRepository implements PaymentRepository {
  ApiPaymentRepository(this._api);
  final ApiClient _api;

  @override
  Future<void> payAndBook(BookingPayment b) async {
    final d = b.day;
    await _api.post('/appointments', body: {
      'dietitian_id': b.dietitianId,
      'day': '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      'time': b.time,
      'mode': b.mode == ConsultMode.video ? 'video' : 'office',
      'method': b.method.wire,
      'phone': b.phone,
    });
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) =>
    ApiConfig.isConfigured
        ? ApiPaymentRepository(ref.watch(apiClientProvider))
        : MockPaymentRepository());
