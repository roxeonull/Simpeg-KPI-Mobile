import 'pegawai.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final Pegawai? pegawai;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.pegawai,
  });

  bool get isAtasan => role == 'atasan';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'pegawai',
        pegawai: json['pegawai'] != null ? Pegawai.fromJson(json['pegawai']) : null,
      );
}
