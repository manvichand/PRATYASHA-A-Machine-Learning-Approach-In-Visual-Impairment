class PredictedCurrency {
  final String predictedCurrency;

  PredictedCurrency(this.predictedCurrency);

  factory PredictedCurrency.fromJson(Map<String, dynamic> json) {
    return PredictedCurrency(json['predicted_currency'] ?? '');
  }
}
