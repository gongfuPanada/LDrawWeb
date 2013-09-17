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
	response.transform(new StringDecoder()).toList().then((data) {
	    callback(data.join('').split('\n'));
	    client.close();
	  });
      });
}
