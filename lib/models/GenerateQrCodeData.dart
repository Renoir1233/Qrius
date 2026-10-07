class QRCode {
  final String lectureId;
  final String course;
  final String module;
  final String dateCreated;
  final DateTime expirationTime;
  final String secrecyCode;
  final double latitude; // new
  final double longitude; // new

  QRCode({
    required this.lectureId,
    required this.course,
    required this.module,
    required this.dateCreated,
    required this.expirationTime,
    required this.secrecyCode,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'lectureId': lectureId,
    'course': course,
    'module': module,
    'dateCreated': dateCreated,
    'expirationTime': expirationTime.toIso8601String(),
    'secrecyCode': secrecyCode,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory QRCode.fromMap(Map<String, dynamic> map) => QRCode(
    lectureId: map['lectureId'],
    course: map['course'],
    module: map['module'],
    dateCreated: map['dateCreated'],
    expirationTime: DateTime.parse(map['expirationTime']),
    secrecyCode: map['secrecyCode'],
    latitude: (map['latitude'] ?? 0.0).toDouble(),
    longitude: (map['longitude'] ?? 0.0).toDouble(),
  );
}
