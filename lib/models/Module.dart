class ModuleModel {
  final String name;
  final String code;
  final String lecturer;

  ModuleModel({required this.name, required this.code, required this.lecturer});

  factory ModuleModel.fromMap(Map<String, dynamic> data) {
    return ModuleModel(
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      lecturer: data['lecturer'] ?? '',
    );
  }
}
