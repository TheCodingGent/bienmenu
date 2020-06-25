class Restaurant {
  final String id;
  final String name;
  final List<String> menus;

  Restaurant({this.id, this.name, this.menus});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'],
      name: json['name'],
      menus: json['menus'].cast<String>(),
    );
  }
}
