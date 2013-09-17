// Copyright 2013 Park "segfault" Joon Kyu <segfault87@gmail.com>

part of ldraw;

const int DIMENSIONS = 3;

class KdNodeData<T> {
  Vec4 vec;
  T tag;

  KdNodeData(this.vec, this.tag);

  String toString() => '$tag at $vec';
}

class KdNode<T> {
  KdNodeData<T> data;
  KdNode left;
  KdNode right;
  KdNode parent;
  int dimension;

  KdNode(this.data, this.dimension, this.parent);
}

class BestMatch<T> {
  KdNode<T> node;
  num distance;
  
  BestMatch(this.node, this.distance);
}

class KdTree<T> {
  KdNode<T> root;

  KdTree() {
    root = null;
  }

  KdTree.fromList(List<Vec4> points, List<T> tags) {
    List<KdNodeData<T>> interweaved = new List<KdNodeData<T>>();
    for (int i = 0; i < points.length; ++i) {
      T tag;
      if (tags == null || i >= tags.length)
	tag = null;
      else
	tag = tags[i];
      interweaved.add(new KdNodeData<T>(points[i], tag));
    }

    root = buildTree(interweaved, 0, null);
  }

  KdNode buildTree(List<KdNodeData<T>> data, int depth, KdNode parent) {
    int dim = depth % DIMENSIONS;

    if (data.length == 0)
      return null;
    if (data.length == 1) {
      return new KdNode(data[0], dim, parent);
    }

    data.sort((KdNodeData a, KdNodeData b) => a.vec[dim] - b.vec[dim]);

    int median = (data.length / 2.0).floor();
    KdNode<T> node = new KdNode<T>(data[median], dim, parent);
    node.left = buildTree(data.sublist(0, median), depth + 1, node);
    node.right = buildTree(data.sublist(median + 1), depth + 1, node);
    
    return node;
  }

  bool insert(Vec4 point, T tag, {bool overwrite: false}) {
    KdNodeData<T> existing = exact(point);
    if (existing != null) {
      if (overwrite) {
	existing.tag = tag;
	return true;
      } else {
	return false;
      }
    }
    
    KdNode<T> innerSearch(KdNode node, KdNode parent) {
      if (node == null)
	return parent;

      int dimension = node.dimension;
      if (point[dimension] < node.data.vec[dimension])
	return innerSearch(node.left, node);
      else
	return innerSearch(node.right, node);
    }

    KdNodeData<T> nodeData = new KdNodeData<T>(point, tag);
    KdNode<T> insertPosition = innerSearch(root, null);
    if (insertPosition == null) {
      root = new KdNode<T>(nodeData, 0, null);
      return true;
    }

    KdNode<T> newNode = new KdNode<T>(nodeData,
				      (insertPosition.dimension + 1) % DIMENSIONS,
				      insertPosition);
    int dimension = insertPosition.dimension;
    
    if (point[dimension] < insertPosition.data.vec[dimension])
      insertPosition.left = newNode;
    else
      insertPosition.right = newNode;

    return true;
  }

  void remove(Vec4 point) {
    KdNode<T> nodeSearch(KdNode<T> node) {
      if (node == null)
	return null;
      
      if (Vec4.equals(node.data.vec, point))
	return node;

      int dimension = node.dimension;

      if (point[dimension] < node.data.vec[dimension])
	return nodeSearch(node.left);
      else
	return nodeSearch(node.right);
    }

    void removeNode(KdNode<T> node) {
      KdNode<T> findMax(KdNode<T> node, int dim) {
	if (node == null)
	  return null;

	if (node.dimension == dim) {
	  if (node.right != null)
	    return findMax(node.right, dim);
	  return node;
	}

	KdNode<T> left = findMax(node.left, dim);
	KdNode<T> right = findMax(node.right, dim);
	KdNode<T> max = node;

	if (left != null && left.data.vec[dim] > node.data.vec[dim])
	  max = left;
	if (right != null && right.data.vec[dim] > max.data.vec[dim])
	  max = right;

	return max;
      }

      KdNode<T> findMin(KdNode<T> node, int dim) {
	if (node == null)
	  return null;

	if (node.dimension == dim) {
	  if (node.left != null)
	    return findMin(node.left, dim);
	  return node;
	}

	KdNode<T> left = findMin(node.left, dim);
	KdNode<T> right = findMin(node.right, dim);
	KdNode<T> min = node;

	if (left != null && left.data.vec[dim] < node.data.vec[dim])
	  min = left;
	if (right != null && right.data.vec[dim] < min.data.vec[dim])
	  min = right;

	return min;
      }

      if (node.left == null && node.right == null) {
	if (node.parent == null) {
	  root = null;
	  return;
	}

	int pdim = node.parent.dimension;
	
	if (node.data.vec[pdim] < node.parent.data.vec[pdim])
	  node.parent.left = null;
	else
	  node.parent.right = null;

	return;
      }

      KdNode<T> nextNode;
      KdNodeData<T> nextData;
      if (node.left != null)
	nextNode = findMax(node.left, node.dimension);
      else
	nextNode = findMin(node.right, node.dimension);
      nextData = nextNode.data;
      removeNode(nextNode);
      node.data = nextData;
    }

    KdNode<T> node = nodeSearch(root);
    
    if (node == null)
      return;

    removeNode(node);
  }

  KdNodeData<T> exact(Vec4 point) {
    List<KdNodeData<T>> result = nearestMultiple(point, 1);

    if (result == null || result.length == 0)
      return null;

    if (result[0].vec == point)
      return result[0];
    else
      return null;
  }

  KdNodeData<T> nearest(Vec4 point) {
    if (root == null)
      return null;

    KdNode<T> min = root;

    KdNode<T> findNearest(KdNode<T> node, int depth) {
      if (node == null)
	return min;

      int dimension = depth % DIMENSIONS;
      num dist = point[dimension] - min.data.vec[dimension];

      KdNode<T> near, far;
      if (dist <= 0.0) {
	near = node.left;
	far = node.right;
      } else {
	near = node.right;
	far = node.left;
      }

      min = findNearest(near, depth + 1);
      if (dist * dist < Vec4.distance(point, min.data.vec))
	min = findNearest(far, depth + 1);
      if (Vec4.distance(point, node.data.vec) < Vec4.distance(point, min.data.vec))
	min = node;

      return min;
    }

    findNearest(root, 0);
    
    return min.data;
  }

  List<KdNodeData<T>> nearestMultiple(Vec4 point, int maxNodes) {
    BinaryHeap<BestMatch<T>> bestNodes = new BinaryHeap<BestMatch<T>>((BestMatch i) => -i.distance);
    
    void nearestSearch(KdNode<T> node) {
      if (node == null)
	return;

      KdNode<T> bestChild, otherChild;
      int dimension = node.dimension;
      num ownDistance = Vec4.distance(point, node.data.vec);
      Vec4 linearPoint = new Vec4();
      num linearDistance;
      
      void saveNode(KdNode<T> item, num distance) {
	bestNodes.push(new BestMatch<T>(item, distance));
	if (bestNodes.size() > maxNodes)
	  bestNodes.pop();
      }

      for (int i = 0; i < DIMENSIONS; ++i) {
	if (i == node.dimension)
	  linearPoint[i] = point[i];
	else
	  linearPoint[i] = node.data.vec[i];
      }

      linearDistance = Vec4.distance(linearPoint, node.data.vec);

      if (node.right == null && node.left == null) {
	if (bestNodes.size() < maxNodes || ownDistance < bestNodes.peek().distance)
	  saveNode(node, ownDistance);
	return;
      }

      if (node.right == null) {
	bestChild = node.left;
      } else if (node.left == null) {
	bestChild = node.right;
      } else {
	if (point[dimension] < node.data.vec[dimension])
	  bestChild = node.left;
	else
	  bestChild = node.right;
      }

      nearestSearch(bestChild);

      if (bestNodes.size() < maxNodes || ownDistance < bestNodes.peek().distance)
	saveNode(node, ownDistance);

      if (bestNodes.size() < maxNodes || linearDistance.abs() < bestNodes.peek().distance) {
	if (bestChild == node.left)
	  otherChild = node.right;
	else
	  otherChild = node.left;
	
	if (otherChild != null)
	  nearestSearch(otherChild);
      }
    }

    nearestSearch(root);
    
    List<KdNodeData<T>> result = new List<KdNodeData<T>>();

    for (int i = 0; i < maxNodes; ++i) {
      if (i < bestNodes.size() && bestNodes.content[i].node != null)
	result.add(bestNodes.content[i].node.data);
    }

    return result;
  }
  
}

class BinaryHeap<T> {
  List<T> content;
  Function scoreFunction;

  BinaryHeap(Function scoreFunction) {
    content = new List<T>();
    this.scoreFunction = scoreFunction;
  }

  void push(T elem) {
    content.add(elem);
    bubbleUp(content.length - 1);
  }

  T pop() {
    if (content.length == 0)
      return null;

    T result = content[0];
    T end = content.removeLast();
    
    if (content.length > 0) {
      content[0] = end;
      sinkDown(0);
    }

    return result;
  }

  T peek() {
    if (content.length == 0)
      return null;
    
    return content[0];
  }

  void remove(T val) {
    int len = content.length;
    for (int i = 0; i < len; ++i) {
      if (content[i] == val) {
	T end = content.removeLast();
	if (i != len - 1) {
	  content[i] = end;
	  if (scoreFunction(end) < scoreFunction(val))
	    bubbleUp(i);
	  else
	    sinkDown(i);
	}
	return;
      }
    }
  }

  int size() {
    return content.length;
  }

  void bubbleUp(int n) {
    T element = content[n];

    while (n > 0) {
      int parentN = (((n + 1) / 2) - 1).floor();
      T parent = content[parentN];

      if (scoreFunction(element) < scoreFunction(parent)) {
	content[parentN] = element;
	content[n] = parent;
	n = parentN;
      } else {
	break;
      }
    }
  }

  void sinkDown(int n) {
    int length = content.length;
    T element = content[n];
    num elemScore = scoreFunction(element);

    while (true) {
      int child2N = (n + 1) * 2;
      int child1N = child2N - 1;
      num child1Score, child2Score;

      int swap = -1;
      if (child1N < length) {
	T child1 = content[child1N];
	child1Score = scoreFunction(child1);
	
	if (child1Score < elemScore)
	  swap = child1N;
      }

      if (child2N < length) {
	T child2 = content[child2N];
	child2Score = scoreFunction(child2);

	if (child2Score < (swap == -1 ? elemScore : child1Score))
	  swap = child2N;
      }

      if (swap != -1) {
	content[n] = content[swap];
	content[swap] = element;
	n = swap;
      } else {
	break;
      }
    }
  }
}