package kr.influx.ldrawweb.client.meshgen;

import java.util.ArrayList;

import kr.influx.ldrawweb.shared.Vector3;

import com.savarese.spatial.KDTree;

public class VertexCloud {
	private KDTree<Float, Vector3, Integer> vertexSet;
	private ArrayList<Vector3> vertexList;
	private int counter = 0;
	
	public VertexCloud() {
		reset();
	}
	
	public void reset() {
		vertexSet = new KDTree<Float, Vector3, Integer>(3);
		vertexList = new ArrayList<Vector3>();
		counter = 0;
	}
	
	public void put(Vector3 vertex) {
		if (!vertexSet.containsKey(vertex)) {
			vertexSet.put(vertex, ++counter);
			vertexList.add(vertex);
		}
	}
	
	public int get(Vector3 vertex) {
		Integer i = vertexSet.get(vertex);
		
		if (i == null)
			return -1;
		else
			return i;
	}
	
	public float[] toArray() {
		if (counter == 0)
			return null;
		
		float[] array = new float[vertexList.size() * 3];
		int idx = 0;
		for (Vector3 v : vertexList) {
			array[idx++] = v.x();
			array[idx++] = v.y();
			array[idx++] = v.z();
		}
		
		return array;
	}
}
