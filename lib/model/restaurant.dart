import 'package:bienmenu/model/menu.dart';

class Restaurant {
  final String id;
  final String name;
  final String city;
  final String address;
  final List<Menu> menus;
  final double rating;
  final String color;

  Restaurant(
      {this.id,
      this.name,
      this.city,
      this.address,
      this.menus,
      this.rating,
      this.color});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        id: json['_id'],
        name: json['name'],
        city: json['city'],
        address: json['address'],
        menus: json['menus'].map<Menu>((json) => Menu.fromJson(json)).toList(),
        rating: json['rating'],
        color: json['color']);
  }
}
