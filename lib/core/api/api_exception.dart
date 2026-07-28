class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  /// Ambil pesan error pertama dari validasi Laravel, kalau ada.
  String get friendlyMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.first;
    }
    return message;
  }

  @override
  String toString() => friendlyMessage;
}
