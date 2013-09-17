// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

class ResolverException implements Exception {
  String message;

  ResolverException(this.message);

  String toString() => this.message;
}

class Resolver {
  const int TAG_NOT_LOADED = -4;
  const int TAG_TO_BE_LOADED = -3;
  const int TAG_LOADING = -2;
  const int TAG_NOT_FOUND = -1;
  const int TAG_DAT_PRESENT = 1;
  
  Map<String, int> registry;
  Map<String, LDrawModel> datFiles;

  Resolver() {
    registry = new HashMap<String, int>();
    datFiles = new HashMap<String, LDrawModel>();
  }

  Resolver.fromJson(Map json) {
    registry = json['registry'];
    datFiles = new HashMap<String, LDrawModel>();

    json['datFiles'].forEach((key, value) {
      datFiles[key] = new LDrawModel.fromJson(value);
    });
  }

  Iterable<String> getItemsDatLoaded() {
    return registry.keys.where((String key) => registry[key] == TAG_DAT_PRESENT);
  }

  Iterable<String> getItemsToBeLoaded() {
    return registry.keys.where((String key) => registry[key] == TAG_TO_BE_LOADED);
  }

  Iterable<String> getItemsInQueue() {
    return registry.keys.where((String key) => registry[key] <= TAG_LOADING);
  }
  
  void cyclicRefTest(LDrawModel model, {LDrawModel base: null,
	Set<LDrawModel> stack: null}) {
    if (stack == null)
      stack = new HashSet<LDrawModel>();
    if (base == null)
      base = model;

    if (stack.contains(model))
      throw new ResolverException('Cyclic reference in $model');

    stack.add(model);

    for (LDrawLine1 cmd in model.filterRefCmds()) {
      LDrawModel ref = base.findPart(cmd.name);
      if (ref == null)
	ref = getPart(cmd.name);
      if (ref == null)
	continue;
      
      cyclicRefTest(ref, stack: stack, base: base);
    }

    stack.remove(model);
  }

  void resolveModel(LDrawModel base,
		    {void onUpdate(String name, LDrawModel model): null,
		     void onFinished(): null}) {
    cyclicRefTest(base); // Find cyclic refs for subparts only

    void traverse(LDrawModel model) {
      for (LDrawLine1 cmd in model.filterRefCmds()) {
	LDrawModel subpart = base.findPart(cmd.name);
	if (subpart != null) {
	  traverse(subpart);
	} else {
	  String partName = normalizePath(cmd.name);
	  if (queryPart(partName) == TAG_NOT_LOADED) {
	    registry[partName] = TAG_TO_BE_LOADED;
	  }
	}
      }
      
      for (String s in getItemsToBeLoaded()) {
	s = normalizePath(s);
	registry[s] = TAG_LOADING;
	String uri = DAT_ENDPOINT + 'g/$s';
	httpGetPlainText(uri, (List<String> response) {
	    LDrawModel newModel = new LDrawModel();
	    try {
	      parseModel(newModel, response.iterator);
	    } catch (e) {
	      registry[s] = TAG_NOT_FOUND;
	      if (onUpdate != null)
		onUpdate(s, null);
	      if (onFinished != null && getItemsInQueue().isEmpty)
		onFinished();
	      return;
	    }
	    datFiles[s] = newModel;
	    registry[s] = TAG_DAT_PRESENT;
	    traverse(newModel);
	    if (onUpdate != null)
	      onUpdate(s, newModel);
	    if (getItemsInQueue().isEmpty) {
	      cyclicRefTest(base);
	      if (onFinished != null)
		onFinished();
	    }
	  },
	  onFailed: () {
	    registry[s] = TAG_NOT_FOUND;
	    if (onUpdate != null)
	      onUpdate(s, null);
	    if (getItemsInQueue().isEmpty) {
	    cyclicRefTest(base);
	    if (onFinished != null)
	      onFinished();
	    }
	  });
      }
    }

    traverse(base);
  }

  int queryPart(String partName) {
    partName = normalizePath(partName);
    if (!registry.containsKey(partName))
      return TAG_NOT_LOADED;
    return registry[partName];
  }

  LDrawModel getPart(String partName) {
    if (queryPart(partName) != TAG_DAT_PRESENT)
      return null;

    return datFiles[normalizePath(partName)];
  }

  Map toJson() {
    return {
      'registry': registry,
      'datFiles': datFiles
    };
  }
}
