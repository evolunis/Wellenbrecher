import 'package:http/http.dart' as http;

dynamic fetchGet(url) async {
  var response = await http.get(Uri.parse(url), headers: {});
  if (response.statusCode == 200) {
    return true;
  } else {
    return 0;
  }
}

dynamic fetchPost(url, Map<String, String>? args) async {
  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {},
      body: args,
    );
    return response;
  } catch (e) {
    return false;
  }
}
