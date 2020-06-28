class Menu {
  final String id;
  final String name;
  final String restaurantId;
  final String type;
  final String url;

  Menu({this.id, this.name, this.restaurantId, this.type, this.url});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(id: json['_id'], name: json['name'], url: json['url']);
  }
}
