class WatchSize {
  final int id;
  final double? caseDiameter;
  final double? thickness;
  final double? bandWidth;
  final double? bandLength;

  WatchSize({
    required this.id,
    required this.caseDiameter,
    required this.thickness,
    required this.bandWidth,
    required this.bandLength,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caseDiameter': caseDiameter,
      'thickness': thickness,
      'bandWidth': bandWidth,
      'bandLength': bandLength,
    };
  }

  factory WatchSize.fromMap(Map<String, dynamic> map) {
    return WatchSize(
      id: map['id'],
      caseDiameter: map['caseDiameter'],
      thickness: map['thickness'],
      bandWidth: map['bandWidth'],
      bandLength: map['bandLength'],
    );
  }
}
