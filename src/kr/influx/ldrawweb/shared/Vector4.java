package kr.influx.ldrawweb.shared;

public class Vector4 extends Vector3 {
	private static final long serialVersionUID = 1L;
	
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
		super(x, y, z);
	}
	
	public Vector4(float x, float y, float z, float w) {
		data = new float[] { x, y, z, w };
	}
	
	public Vector4(Vector4 orig) {
		try {
			data = (float[]) orig.clone();
		} catch (CloneNotSupportedException e) {
			data = new float[] { orig.x(), orig.y(), orig.z(), orig.w() };
		}
	}
	
	public boolean identical(Vector4 other) {
		return data[0] == other.data[0] && data[1] == other.data[1] && data[2] == other.data[2] && data[3] == other.data[3];
	}
	
	public float w() {
		return data[3];
	}
	
	public String toString() {
		return "(" + data[0] + ", " + data[1] + ", " + data[2] + ", " + data[3] + ")";
	}
}
