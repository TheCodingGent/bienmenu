class Menu {
  final String id;
  final String name;
  final String filename;
  final String lastUpdated;

  Menu({this.id, this.name, this.filename, this.lastUpdated});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
        id: json['_id'],
        name: json['name'],
        filename: json['filename'],
        lastUpdated: json['lastupdated']);
  }
}
