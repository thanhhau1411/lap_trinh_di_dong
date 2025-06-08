class Customer {
  late int? id;
  late String fullName;
  late String? email;
  late String phoneNumer;
  late String address;
  Customer({
    this.id,
    required this.fullName,
    this.email,
    required this.phoneNumer,
    required this.address
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumer': phoneNumer,
      'address': address
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      phoneNumer: map['phoneNumer'],
      address: map['address']
    );
  }
}
