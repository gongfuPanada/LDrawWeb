// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

// Unified interface to HTTP client (server-side)

void httpGetPlainText(String uri, void callback(List<String> response),
		      {void onFailed(int status): null}) {
  HttpClient client = new HttpClient();
  client.getUrl(Uri.parse(uri))
    .then((HttpClientRequest request) {
      return request.close();
    })
    .then((HttpClientResponse response) {
      if (response.statusCode / 100 >= 4) {
        if (onFailed != null)
          onFailed(response.statusCode);
        return;
      }
      response.toList().then((data) {
        callback(new String.fromCharCodes(data[0]).split('\n'));
        client.close();
      });
    });
}

void httpGetJson(String uri, void callback(response),
                 {void onFailed(int status): null}) {
  HttpClient client = new HttpClient();
  client.getUrl(Uri.parse(uri))
    .then((HttpClientRequest request) {
	return request.close();
      })
    .then((HttpClientResponse response) {
      if (response.statusCode / 100 >= 4) {
        if (onFai/led != null)
          onFailed(response.statusCode);
        return;
      }
      response.toList().then((data) {
        callback(JSON.decode(new String.fromCharCodes(data[0])));
        client.close();
      });
    });
}
