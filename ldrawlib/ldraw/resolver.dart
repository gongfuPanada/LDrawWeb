// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

class ResolverException implements Exception {
  String message;

  ResolverException(this.message);

  String toString() => this.message;
}

class Resolver {
  int TAG_NOT_LOADED = -4;
  int TAG_TO_BE_LOADED = -3;
  int TAG_LOADING = -2;
  int TAG_NOT_FOUND = -1;
  int TAG_DAT_PRESENT = 1;
  
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

  void resolveModelLocally(LDrawModel base, String ldrawPath,
                           {void onUpdate(String name, LDrawModel model): null}) {
    cyclicRefTest(base);

    File searchPart(String partName) {
      File p = new File('$ldrawPath/p/$partName');
      File parts = new File('$ldrawPath/parts/$partName');

      if (parts.existsSync())
        return parts;
      else if (p.existsSync())
        return p;

      return null;
    }

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
      
      List<String> itemsToBeLoaded = new List.from(getItemsToBeLoaded());
      for (String s in itemsToBeLoaded) {
        s = normalizePath(s);
        if (registry.containsKey(s) && registry[s] == TAG_DAT_PRESENT)
          continue;
        File f = searchPart(s);
        if (f == null) {
          print('part $s not found!');
          registry[s] = TAG_NOT_FOUND;
        } else {
          List<String> contents;
          try {
            contents = f.readAsLinesSync(encoding: UTF8);
          } catch (FileSystemException) {
            contents = f.readAsLinesSync(encoding: LATIN1);
          }
          LDrawModel newModel = new LDrawModel();
          try {
            parseModel(newModel, contents.iterator);
          } catch (e) {
            registry[s] = TAG_NOT_FOUND;
            if (onUpdate != null)
              onUpdate(s, null);
            return;
          }
          datFiles[s] = newModel;
          registry[s] = TAG_DAT_PRESENT;
          if (onUpdate != null)
            onUpdate(s, newModel);
          traverse(newModel);
        }
      }
    }

    traverse(base);
    cyclicRefTest(base);
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
        onFailed: (int resCode) {
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
