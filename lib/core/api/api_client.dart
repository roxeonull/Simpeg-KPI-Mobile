import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Dio get dio => _dio;

  /// Membungkus semua request supaya error dari Laravel (422/401/dst)
  /// diterjemahkan jadi [ApiException] yang mudah ditampilkan di UI.
  Future<Response> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? query,
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.request(
        path,
        queryParameters: query,
        data: data,
        options: (options ?? Options()).copyWith(method: method),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final response = e.response;
    if (response == null) {
      return ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }

    final data = response.data;
    String message = 'Terjadi kesalahan. Silakan coba lagi.';
    Map<String, List<String>>? errors;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) message = data['message'].toString();
      if (data['errors'] is Map) {
        errors = (data['errors'] as Map).map(
          (key, value) => MapEntry(key.toString(), List<String>.from(value)),
        );
      }
    }

    if (response.statusCode == 401) {
      message = 'Sesi Anda telah berakhir. Silakan masuk kembali.';
    }

    return ApiException(message, statusCode: response.statusCode, errors: errors);
  }
}
