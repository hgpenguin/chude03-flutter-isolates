class ParseSummary {
  const ParseSummary({required this.count, required this.totalAmount});

  final int count;
  final int totalAmount;

  @override
  bool operator ==(Object other) =>
      other is ParseSummary &&
      count == other.count &&
      totalAmount == other.totalAmount;

  @override
  int get hashCode => Object.hash(count, totalAmount);

  @override
  String toString() => 'ParseSummary(count: $count, totalAmount: $totalAmount)';
}
