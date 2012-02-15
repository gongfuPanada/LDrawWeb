package kr.influx.ldrawweb.shared;

import java.io.Serializable;

import com.savarese.spatial.Point;

public class Vector3 implements Serializable, Point<Float> {
	private static final long serialVersionUID = 1L;
	
	protected float[] data;
	
	public Vector3() {
		data = new float[] { 0.0f, 0.0f, 0.0f };
	}
	
	public Vector3(float[] data) {
		if (data.length == 3) {
			this.data = data;
		} else {
			throw new ArithmeticException();
		}
	}
	
	public Vector3(float x, float y, float z) {
		data = new float[] { x, y, z };
	}
	
	public Vector3(Vector3 orig) {
		data = new float[] { orig.x(), orig.y(), orig.z() };
	}
	
	public float x() {
		return data[0];
	}
	
	public float y() {
		return data[1];
	}
	
	public float z() {
		return data[2];
	}
	
	public float[] getData() {
		return data;
	}
	
	public void setData(float[] data) {
		if (data.length != 3)
			throw new ArithmeticException();
		
		this.data = data;
	}

	public void setCoord(int i, float d) {
		data[i] = d;
	}
	
	public Vector4 normalize() {
		float r = length();
		
		if (r != 0.0f)
			return new Vector4(data[0] / r, data[1] / r, data[2] / r);
		else
			return new Vector4();
	}
	
	public float length() {
		return (float) Math.sqrt(data[0]*data[0] + data[1]*data[1] + data[2]*data[2]);
	}
	
	public boolean identical(Vector3 other) {
		return data[0] == other.data[0] && data[1] == other.data[1] && data[2] == other.data[2];
	}
	
	public String toString() {
		return "(" + data[0] + ", " + data[1] + ", " + data[2] + ")";
	}
	
	static public Vector3 add(Vector3 a, Vector3 b) {
		return new Vector4(a.x() + b.x(), a.y() + b.y(), a.z() + b.z());
	}
	
	static public Vector3 sub(Vector3 a, Vector3 b) {
		return new Vector4(a.x() - b.x(), a.y() - b.y(), a.z() - b.z());
	}
	
	static public Vector3 cross(Vector3 a, Vector3 b) {
		return new Vector4(a.y()*b.z() - a.z()*b.y(), a.z()*b.x() - a.x()*b.z(), a.x()*b.y() - a.y()*b.x());
	}
	
	static public float dot(Vector3 a, Vector3 b) {
		return a.x()*b.x() + a.y()*b.y() + a.z()*b.z();
	}

	@Override
	public Float getCoord(int dimension) {
		return data[dimension];
	}

	@Override
	public int getDimensions() {
		return 3;
	}
	
	@Override
	public boolean equals(Object other) {
		Vector3 o = (Vector3) other;
		
		return x() == o.x() && y() == o.y() && z() == o.z();
	}
}
