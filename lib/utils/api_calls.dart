import 'package:http/http.dart' as http;

Future<http.Response> fetchGet(url) {
  return http.get(Uri.parse(url), headers: {'Content-Type': 'text/plain'});
}
