class ApiError implements Exception {
  final int status;
  final String message;
  ApiError(this.status, this.message);
}
