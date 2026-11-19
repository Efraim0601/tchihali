import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/dietitian_repository.dart';
import '../../data/models.dart';

class BookingState {
  const BookingState({
    required this.dietitian,
    required this.mode,
    required this.day,
    required this.slot,
  });
  final Dietitian dietitian;
  final ConsultMode mode;
  final DateTime day; // date seule (minuit)
  final String slot; // « 10:30 »

  int get price => mode.price;

  BookingState copyWith({ConsultMode? mode, DateTime? day, String? slot}) =>
      BookingState(
        dietitian: dietitian,
        mode: mode ?? this.mode,
        day: day ?? this.day,
        slot: slot ?? this.slot,
      );
}

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() => _initial(MockDietitianRepository.fallback);

  static BookingState _initial(Dietitian d) => BookingState(
    dietitian: d,
    mode: d.video ? ConsultMode.video : ConsultMode.office,
    day: _dateOnly(d.nextSlot ?? DateTime.now()),
    slot: d.nextSlot == null ? '' : hhmm(d.nextSlot!),
  );

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Démarre une réservation sur le prochain créneau du diététicien.
  void start(Dietitian d) => state = _initial(d);
  void setMode(ConsultMode m) => state = state.copyWith(mode: m);
  void setDay(DateTime d) =>
      state = state.copyWith(day: DateTime(d.year, d.month, d.day));
  void setSlot(String s) => state = state.copyWith(slot: s);
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(
  BookingNotifier.new,
);
