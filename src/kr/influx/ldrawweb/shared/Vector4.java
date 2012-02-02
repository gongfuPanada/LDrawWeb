package kr.influx.ldrawweb.shared;

import java.io.Serializable;

public class Vector4 implements Serializable {
	private static final long serialVersionUID = 1L;
	private float[] data;
	
	public Vector4() {
		data = new float[] { 0.0f, 0.0f, 0.0f, 1.0f };
	}
	
	public Vector4(float[] data) {
		if (data.length == 4) {
			this.data = data;
		} else if (data.length == 3) {
			this.data = new float[4];
			this.data[0] = data[0];
			this.data[1] = data[1];
			this.data[2] = data[2];
			this.data[3] = 1.0f;
		} else {
			throw new ArithmeticException();
		}
	}
	
	public Vector4(float x, float y, float z) {
		data = new float[] { x, y, z, 1.0f };
	}
	
	public Vector4(float x, float y, float z, float w) {
		data = new float[] { x, y, z, w };
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
	
	public float w() {
		return data[3];
	}
	
	public float[] getData() {
		return data;
	}
	
	public float getData(int i) {
		return data[i];
	}
	
	public void setData(float[] data) {
		if (data.length != 4)
			throw new ArithmeticException();
		
		this.data = data;
	}

	public void setData(int i, float d) {
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
	
	static public Vector4 add(Vector4 a, Vector4 b) {
		return new Vector4(a.x() + b.x(), a.y() + b.y(), a.z() + b.z());
	}
	
	static public Vector4 sub(Vector4 a, Vector4 b) {
		return new Vector4(a.x() - b.x(), a.y() - b.y(), a.z() - b.z());
	}
	
	static public Vector4 cross(Vector4 a, Vector4 b) {
		return new Vector4(a.y()*b.z() - a.z()*b.y(), a.z()*b.x() - a.x()*b.z(), a.x()*b.y() - a.y()*b.x());
	}
	
	static public float dot(Vector4 a, Vector4 b) {
		return a.x()*b.x() + a.y()*b.y() + a.z()*b.z();
	}
}
