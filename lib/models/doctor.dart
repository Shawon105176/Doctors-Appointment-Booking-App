class Doctor {
  final int? id;
  final String name;
  final String specialization;
  final String? phone;
  final String? email;
  final String? address;
  final int experience; // years of experience
  final double rating; // rating out of 5

  Doctor({
    this.id,
    required this.name,
    required this.specialization,
    this.phone,
    this.email,
    this.address,
    this.experience = 0,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'phone': phone,
      'email': email,
      'address': address,
      'experience': experience,
      'rating': rating,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as int?,
      name: map['name'] as String,
      specialization: map['specialization'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      experience: map['experience'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Doctor copyWith({
    int? id,
    String? name,
    String? specialization,
    String? phone,
    String? email,
    String? address,
    int? experience,
    double? rating,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
    );
  }

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialization: $specialization, experience: $experience, rating: $rating)';
  }
}