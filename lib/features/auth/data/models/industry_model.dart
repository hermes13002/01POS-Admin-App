/// model for industry type
class IndustryModel {
  final int id;
  final String name;
  final String slug;

  const IndustryModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory IndustryModel.fromJson(Map<String, dynamic> json) {
    return IndustryModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}
