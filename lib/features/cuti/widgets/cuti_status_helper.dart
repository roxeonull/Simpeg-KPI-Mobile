import '../../../core/widgets/status_badge.dart';

class CutiStatusHelper {
  CutiStatusHelper._();

  static BadgeTone tone(String status) {
    switch (status) {
      case 'disetujui':
        return BadgeTone.success;
      case 'ditolak':
        return BadgeTone.danger;
      case 'menunggu_atasan':
      case 'menunggu_hr':
        return BadgeTone.warning;
      default:
        return BadgeTone.neutral;
    }
  }
}
