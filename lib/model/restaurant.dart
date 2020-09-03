import 'package:bienmenu/model/menu.dart';

class Restaurant {
  final String id;
  final String name;
  final String country;
  final String province;
  final String postalCode;
  final String city;
  final String address;
  final String phone;
  final List<Menu> menus;
  final double rating;
  final String color;
  final bool tracingEnabled;
  final String externalMenuLink;
  final bool hostedInternal;

  Restaurant(
      {this.id,
      this.name,
      this.country,
      this.province,
      this.postalCode,
      this.city,
      this.address,
      this.phone,
      this.menus,
      this.rating,
      this.color,
      this.tracingEnabled,
      this.externalMenuLink,
      this.hostedInternal});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        id: json['_id'],
        name: json['name'],
        country: json['country'],
        province: json['province'],
        postalCode: json['postalCode'],
        city: json['city'],
        address: json['address'],
        phone: json['phone'],
        menus: json['menus'].map<Menu>((json) => Menu.fromJson(json)).toList(),
        rating: json['rating'],
        color: json['color'],
        tracingEnabled: json['tracingEnabled'],
        externalMenuLink: json['externalMenuLink'],
        hostedInternal: json['hostedInternal']);
  }
}
