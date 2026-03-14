import 'package:http/http.dart';

/// A builder for constructing GET requests with common headers.
class GetRequestBuilder {
  late final Request _request;

  GetRequestBuilder(String url) {
    _request = Request('GET', Uri.parse(url));
  }

  GetRequestBuilder addHeader(String key, String value) {
    _request.headers[key] = value;
    return this;
  }

  GetRequestBuilder acceptJson() {
    _request.headers['Accept'] = 'application/json';
    return this;
  }

  Request build() {
    return _request;
  }
}
