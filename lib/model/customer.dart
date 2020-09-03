class Customer {
  String fullname;
  String email;
  String phone;
  String date;
  String restaurant;

  Customer({this.fullname, this.email, this.phone, this.date, this.restaurant});

  Map<String, dynamic> toJson() => {
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'date': date,
        'restaurant': restaurant
      };
}
