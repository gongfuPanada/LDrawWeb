// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

// Unified interface to HTTP client (server-side)

void httpGetPlainText(String uri, void callback(List<String> response),
		      {void onFailed(int status): null}) {
  HttpRequest.request(uri)
    .then((HttpRequest request) {
	if (request.status / 100 >= 4) {
	  if (onFailed != null)
	    onFailed(request.status);
	} else {
	  List<String> lines = request.responseText.split('\n');
	  callback(lines);
	}
      });
}

void httpGetJson(String uri, void callback(response),
		 {void onFailed(int status): null}) {
  HttpRequest.request(uri)
    .then((HttpRequest request) {
	if (request.status / 100 >= 4) {
	  if (onFailed != null)
	    onFailed(request.status);
	} else {
	  callback(parse(request.responseText));
	}
      });
}
