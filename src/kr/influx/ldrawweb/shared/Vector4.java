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
}
