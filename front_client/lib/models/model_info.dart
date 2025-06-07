//front_client\lib\models\model_info.dart
class InfoPanelModel {
  final String title;
  final String description;
  final String color;

  InfoPanelModel({
    required this.title,
    required this.description,
    required this.color,
  });

  factory InfoPanelModel.fromJson(Map<String, dynamic> json) {
    return InfoPanelModel(
      title: json['title'],
      description: json['description'],
      color: json['color'],
    );
  }
}
