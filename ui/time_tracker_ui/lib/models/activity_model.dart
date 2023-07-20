class ActivityResponse {
  final int activityId;
  final String name;
  final double? originalEstimate;
  final double? remainingHours;
  final double? completedHours;
  final bool? finalized;
  final double? pricePerHour;
  final bool? moneyReceived;

  ActivityResponse({
    required this.activityId,
    required this.name,
    required this.originalEstimate,
    required this.remainingHours,
    required this.completedHours,
    required this.finalized,
    required this.pricePerHour,
    required this.moneyReceived,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      activityId: json['activity_id'],
      name: json['name'],
      originalEstimate: json['original_estimate'],
      remainingHours: json['remaining_hours'],
      completedHours: json['completed_hours'],
      finalized: json['finalized'],
      pricePerHour: json['price_per_hour'],
      moneyReceived: json['money_received'],
    );
  }
}

class ActivityCreate {
  final String name;
  final double originalEstimate;

  ActivityCreate(this.name, this.originalEstimate);

  Map<String, dynamic> toJson() {
    return {'name': name, 'original_estimate': originalEstimate};
  }

  // Factory constructor to create ActivityCreate from a Map<String, dynamic>
  factory ActivityCreate.fromMap(Map<String, dynamic> map) {
    double originalEstimate = 0.0;

    if (map['original_estimate'] is int) {
      originalEstimate = (map['original_estimate'] as int).toDouble();
    } else if (map['original_estimate'] is double) {
      originalEstimate = map['original_estimate'] as double;
    } else if (map['original_estimate'] is String) {
      originalEstimate =
          double.tryParse(map['original_estimate'] as String) ?? 0.0;
    }

    return ActivityCreate(
      map['name'] as String,
      originalEstimate,
    );
  }

  // Method to convert ActivityCreate to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'original_estimate': originalEstimate,
    };
  }
}

class ActivityUpdate {
  final String name;
  final double originalEstimate;
  final double completedHours;
  final bool finalized;
  final double pricePerHour;
  final bool moneyReceived;

  ActivityUpdate({
    required this.name,
    required this.originalEstimate,
    required this.completedHours,
    required this.finalized,
    required this.pricePerHour,
    required this.moneyReceived,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'original_estimate': originalEstimate,
      'completed_hours': completedHours,
      'finalized': finalized,
      'price_per_hour': pricePerHour,
      'money_received': moneyReceived,
    };
  }
}
