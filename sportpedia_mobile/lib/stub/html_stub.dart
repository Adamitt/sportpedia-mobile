// chevinka: Stub file untuk dart:html di platform non-web (Android/iOS)
// File ini digunakan untuk avoid error saat build untuk Android
// karena dart:html hanya tersedia di Flutter Web

// Stub untuk HttpRequest (tidak digunakan di Android karena semua request pakai http package)
class HttpRequest {
  static HttpRequest? create() => null;
  HttpRequest();
  void open(String method, String url, {bool? async, String? user, String? password}) {}
  void send([Object? data]) {}
  void setRequestHeader(String name, String value) {}
  int get status => 0;
  String get responseText => '';
  bool get withCredentials => false;
  set withCredentials(bool value) {}
  // chevinka: onLoad dan onError sebagai Stream untuk listen (non-nullable untuk stub)
  Stream<dynamic> get onLoad => const Stream.empty(); // chevinka: Empty stream untuk Android
  Stream<dynamic> get onError => const Stream.empty(); // chevinka: Empty stream untuk Android
}

// Stub untuk document (tidak digunakan di Android)
class Document {
  String get cookie => '';
  set cookie(String value) {}
}

final document = Document();

