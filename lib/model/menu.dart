class Menu {
  final String id;
  final String name;
  final String filename;

  Menu({this.id, this.name, this.filename});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
        id: json['_id'], name: json['name'], filename: json['filename']);
  }
}
