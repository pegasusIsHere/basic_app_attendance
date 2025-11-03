class DivisionModel {
  final String id;
  final String name;
  DivisionModel({required this.id, required this.name});

  factory DivisionModel.fromJson(Map<String, dynamic> j) =>
      DivisionModel(id: j['_id'] as String, name: j['name'] as String);
}
