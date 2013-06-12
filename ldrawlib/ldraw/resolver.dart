// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

class Resolver {
  const int TAG_NOT_LOADED = -4;
  const int TAG_TO_BE_LOADED = -3;
  const int TAG_LOADING = -2;
  const int TAG_NOT_FOUND = -1;
  const int TAG_MESH_PRESENT = 0;
  const int TAG_DAT_PRESENT = 1;
  
  Map<String, int> registry;
  Map<String, LDrawModel> datFiles;
  Map<String, Mesh> meshFiles;

  Resolver() {
    registry = new HashMap<String, int>();
    datFiles = new HashMap<String, LDrawModel>();
  }

  Iterable<String> getItemsToBeLoaded() {
    return registry.keys.where((String key) => registry[key] == TAG_TO_BE_LOADED);
  }

  void resolveModel(LDrawModel model) {
    for (LDrawLine1 cmd in model.filterRefCmds()) {
      LDrawModel subpart = model.findPart(cmd.name);
      if (subpart != null) {
	resolveModel(subpart);
      } else {
	String partName = normalizePath(cmd.name);
	if (queryPart(partName) == TAG_NOT_LOADED) {
	  registry[partName] = TAG_TO_BE_LOADED;
	}
      }
    }

    for (String s in getItemsToBeLoaded()) {
      String uri = DAT_ENDPOINT + 'g/$s';
      print(uri);
      HttpClient client = new HttpClient();
      client.getUrl(Uri.parse(uri))
        .then((HttpClientRequest request) {
          return request.close();
        })
        .then((HttpClientResponse response) {
          print(response);
        });
    }
  }

  int queryPart(String partName) {
    partName = normalizePath(partName);
    if (!registry.containsKey(partName))
      return TAG_NOT_LOADED;
    return registry[partName];
  }
}
