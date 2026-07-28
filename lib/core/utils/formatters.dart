import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _tanggalPanjang = DateFormat('d MMMM yyyy', 'id_ID');
  static final _tanggalPendek = DateFormat('d MMM yyyy', 'id_ID');
  static final _tanggalRingkas = DateFormat('d MMM', 'id_ID');
  static final _hariTanggal = DateFormat('EEEE, d MMMM', 'id_ID');

  static String tanggalPanjang(DateTime date) => _tanggalPanjang.format(date);
  static String tanggalPendek(DateTime date) => _tanggalPendek.format(date);
  static String tanggalRingkas(DateTime date) => _tanggalRingkas.format(date);
  static String hariTanggal(DateTime date) => _hariTanggal.format(date);

  static String rentangTanggal(DateTime mulai, DateTime selesai) {
    if (mulai.year == selesai.year && mulai.month == selesai.month) {
      return '${mulai.day} - ${_tanggalPendek.format(selesai)}';
    }
    return '${_tanggalRingkas.format(mulai)} - ${_tanggalPendek.format(selesai)}';
  }

  static String jenisCuti(String jenis) {
    switch (jenis) {
      case 'tahunan':
        return 'Cuti Tahunan';
      case 'sakit':
        return 'Cuti Sakit';
      case 'melahirkan':
        return 'Cuti Melahirkan';
      default:
        return 'Cuti Lainnya';
    }
  }

  static String kategoriPelatihan(String kategori) {
    switch (kategori) {
      case 'struktural':
        return 'Struktural';
      case 'fungsional':
        return 'Fungsional';
      case 'teknis':
        return 'Teknis';
      case 'latsar':
        return 'Latsar';
      default:
        return 'Lainnya';
    }
  }
}
