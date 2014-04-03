// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

// Unified interface to HTTP client (server-side)

void httpGetPlainText(String uri, void callback(List<String> response),
		      {void onFailed(int status): null}) {
  HttpRequest.request(uri)
    .then((HttpRequest request) {
      List<String> lines = request.responseText.split('\n');
      callback(lines);
    })
    .catchError((Error error) {
      if (onFailed != null) {
        onFailed(404);
      }
    });
}

void httpGetJson(String uri, void callback(response),
		 {void onFailed(int status): null}) {
  HttpRequest.request(uri)
    .then((HttpRequest request) {
      callback(JSON.decode(request.responseText));
    })
    /*.catchError((Error error) {
      if (onFailed != null) {
        onFailed(404);
      }
    })*/;
}
