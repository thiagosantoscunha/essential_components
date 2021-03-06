class BadRequestException implements Exception {
  String message;
  
  BadRequestException([this.message]);

  String toString() {
    if (message == null) return 'BadRequestException';
    return 'BadRequestException: $message';
  }
}
