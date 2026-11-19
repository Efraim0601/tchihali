/// Courbes de suivi de la patiente de test (12 semaines, 24 août → 15 novembre).
class ProgressSeries {
  const ProgressSeries({
    required this.unit,
    required this.data,
    required this.goal,
    required this.min,
    required this.max,
  });
  final String unit;
  final List<double> data;
  final double goal;
  final double min;
  final double max;
}

const _weight = [
  84.0,
  83.4,
  83.1,
  82.5,
  82.2,
  81.6,
  81.4,
  80.9,
  80.5,
  80.2,
  79.9,
  79.6,
];

final progressSeries = [
  const ProgressSeries(unit: 'kg', data: _weight, goal: 75, min: 74, max: 85),
  ProgressSeries(
    unit: '',
    data: [for (final w in _weight) w / (1.65 * 1.65)],
    goal: 27.5,
    min: 27,
    max: 31.5,
  ),
  const ProgressSeries(
    unit: 'cm',
    data: [98, 97.5, 97, 96, 95.5, 95, 94.5, 94, 93.5, 93, 92.5, 92],
    goal: 88,
    min: 87,
    max: 99,
  ),
];
