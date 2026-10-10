class ApiException implements Exception {

  //nếu mà bên BE mà có mấy cái exception thì có thể lưu lại mà sài quài quài thì càng tốt.
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
