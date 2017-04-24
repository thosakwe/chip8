class ChipException implements Exception {
  final String message;
  final data;

  ChipException(this.message, [this.data]);

  @override
  String toString() {
    return data != null ? '$message: $data' : message;
  }
}
