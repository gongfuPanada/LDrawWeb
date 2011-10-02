package kr.influx.ldrawweb.shared;

import java.io.Serializable;

public class Matrix4 implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private float[] data;
	
	static public Matrix4 createFrustumMatrix(float left, float right, float bottom, float top, float near, float far) {
		float rl = right - left;
		float tb = top - bottom;
		float fn = far - near;
		
		return new Matrix4(new float[] {
				(near*2) / rl, 0.0f, 0.0f, 0.0f,
				0.0f, (near*2) / tb, 0.0f, 0.0f,
				(right + left) / rl, (top + bottom) / tb, -(far + near) / fn, -1.0f,
				0.0f, 0.0f, -(far * near * 2) / fn, 0.0f
		});
	}
	
	static public Matrix4 createPerspectiveMatrix(float fov, float aspectRatio, float near, float far) {
		float top = near * (float)Math.tan(fov * Math.PI / 360.0);
		float right = top * aspectRatio;
		
		return createFrustumMatrix(-right, right, -top, top, near, far);
	}
	
	public Matrix4() {
		data = new float[] {
				1.0f, 0.0f, 0.0f, 0.0f,
				0.0f, 1.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f
		};
	}
	
	public Matrix4(float[] data) {
		if (data.length == 16)
			this.data = data;
		else if (data.length == 12) {
			this.data = new float[16];
			
			/* x, y, z */
			this.data[3] = data[0];
			this.data[7] = data[1];
			this.data[11] = data[2];
			
			/* a through i */
			this.data[0] = data[3]; this.data[1] = data[4]; this.data[2] = data[5];
			this.data[4] = data[6]; this.data[5] = data[7]; this.data[6] = data[8];
			this.data[8] = data[9]; this.data[9] = data[10];this.data[10]= data[11];
			
			this.data[15] = 1.0f;
		} else
			throw new ArithmeticException();
	}
	
	public float[] getData() {
		return data;
	}
	
	public float getData(int i, int j) {
		return data[i*4 + j];
	}
	
	public void setData(float[] data) {
		if (data.length != 4)
			throw new ArithmeticException();
		
		this.data = data;
	}

	public void setData(int i, int j, float d) {
		data[i*4 + j] = d;
	}
	
	//////////////////////////////
	// math helpers
	//////////////////////////////
	
	/* transpose */
	public Matrix4 transpose() {
		float[] dest = new float[16];
		
		dest[0] = data[0];
        dest[1] = data[4];
        dest[2] = data[8];
        dest[3] = data[12];
        dest[4] = data[1];
        dest[5] = data[5];
        dest[6] = data[9];
        dest[7] = data[13];
        dest[8] = data[2];
        dest[9] = data[6];
        dest[10] = data[10];
        dest[11] = data[14];
        dest[12] = data[3];
        dest[13] = data[7];
        dest[14] = data[11];
        dest[15] = data[15];
        
        return new Matrix4(dest);
	}
	
	/* linear transform */
	public Vector4 translate(Vector4 pos) {
		return new Vector4(new float[] {
				data[0]*pos.x() + data[1]*pos.y() + data[2]*pos.z() + data[3]*pos.w(),
				data[4]*pos.x() + data[5]*pos.y() + data[6]*pos.z() + data[7]*pos.w(),
				data[8]*pos.x() + data[9]*pos.y() + data[10]*pos.z() + data[11]*pos.w(),
				data[12]*pos.x() + data[13]*pos.y() + data[14]*pos.z() + data[15]*pos.w()
			});
	}
	
	/* multiply */
	public Matrix4 multiply(Matrix4 other) {
		/*float a00 = data[0], a01 = data[1], a02 = data[2], a03 = data[3];
		float a10 = data[4], a11 = data[5], a12 = data[6], a13 = data[7];
		float a20 = data[8], a21 = data[9], a22 = data[10], a23 = data[11];
		float a30 = data[12], a31 = data[13], a32 = data[14], a33 = data[15];
		
		float b00 = other.data[0], b01 = other.data[1], b02 = other.data[2], b03 = other.data[3];
		float b10 = other.data[4], b11 = other.data[5], b12 = other.data[6], b13 = other.data[7];
		float b20 = other.data[8], b21 = other.data[9], b22 = other.data[10], b23 = other.data[11];
		float b30 = other.data[12], b31 = other.data[13], b32 = other.data[14], b33 = other.data[15];
		
		float[] dest = new float[16];
		
		dest[0] = b00*a00 + b01*a10 + b02*a20 + b03*a30;
		dest[1] = b00*a01 + b01*a11 + b02*a21 + b03*a31;
		dest[2] = b00*a02 + b01*a12 + b02*a22 + b03*a32;
		dest[3] = b00*a03 + b01*a13 + b02*a23 + b03*a33;
		dest[4] = b10*a00 + b11*a10 + b12*a20 + b13*a30;
		dest[5] = b10*a01 + b11*a11 + b12*a21 + b13*a31;
		dest[6] = b10*a02 + b11*a12 + b12*a22 + b13*a32;
		dest[7] = b10*a03 + b11*a13 + b12*a23 + b13*a33;
		dest[8] = b20*a00 + b21*a10 + b22*a20 + b23*a30;
		dest[9] = b20*a01 + b21*a11 + b22*a21 + b23*a31;
		dest[10] = b20*a02 + b21*a12 + b22*a22 + b23*a32;
		dest[11] = b20*a03 + b21*a13 + b22*a23 + b23*a33;
		dest[12] = b30*a00 + b31*a10 + b32*a20 + b33*a30;
		dest[13] = b30*a01 + b31*a11 + b32*a21 + b33*a31;
		dest[14] = b30*a02 + b31*a12 + b32*a22 + b33*a32;
		dest[15] = b30*a03 + b31*a13 + b32*a23 + b33*a33;
		
		return new Matrix4(dest);*/
		
		float[] dest = new float[16];
		
		for (int i = 0; i < 4; ++i) {
			for (int j = 0; j < 4; ++j) {
				float v = 0.0f;
				for (int k = 0; k < 4; ++k)
					v += getData(i, k) * other.getData(k, j);
				dest[i*4 + j] = v;
			}
		}
		
		return new Matrix4(dest);
	}
	
	/* n = n * m */
	public void multiplied(Matrix4 other) {
		float a00 = data[0], a01 = data[1], a02 = data[2], a03 = data[3];
		float a10 = data[4], a11 = data[5], a12 = data[6], a13 = data[7];
		float a20 = data[8], a21 = data[9], a22 = data[10], a23 = data[11];
		float a30 = data[12], a31 = data[13], a32 = data[14], a33 = data[15];
		
		float b00 = other.data[0], b01 = other.data[1], b02 = other.data[2], b03 = other.data[3];
		float b10 = other.data[4], b11 = other.data[5], b12 = other.data[6], b13 = other.data[7];
		float b20 = other.data[8], b21 = other.data[9], b22 = other.data[10], b23 = other.data[11];
		float b30 = other.data[12], b31 = other.data[13], b32 = other.data[14], b33 = other.data[15];
		
		data[0] = b00*a00 + b01*a10 + b02*a20 + b03*a30;
		data[1] = b00*a01 + b01*a11 + b02*a21 + b03*a31;
		data[2] = b00*a02 + b01*a12 + b02*a22 + b03*a32;
		data[3] = b00*a03 + b01*a13 + b02*a23 + b03*a33;
		data[4] = b10*a00 + b11*a10 + b12*a20 + b13*a30;
		data[5] = b10*a01 + b11*a11 + b12*a21 + b13*a31;
		data[6] = b10*a02 + b11*a12 + b12*a22 + b13*a32;
		data[7] = b10*a03 + b11*a13 + b12*a23 + b13*a33;
		data[8] = b20*a00 + b21*a10 + b22*a20 + b23*a30;
		data[9] = b20*a01 + b21*a11 + b22*a21 + b23*a31;
		data[10] = b20*a02 + b21*a12 + b22*a22 + b23*a32;
		data[11] = b20*a03 + b21*a13 + b22*a23 + b23*a33;
		data[12] = b30*a00 + b31*a10 + b32*a20 + b33*a30;
		data[13] = b30*a01 + b31*a11 + b32*a21 + b33*a31;
		data[14] = b30*a02 + b31*a12 + b32*a22 + b33*a32;
		data[15] = b30*a03 + b31*a13 + b32*a23 + b33*a33;
	}
	
	/* rotate by x */
	public void rotateByX(float degree) {
		float rad = degree * (float)Math.PI / 180.0f;
		
		Matrix4 nm = new Matrix4();
		nm.setData(1, 1, (float)Math.cos(rad));
		nm.setData(1, 2, (float)Math.sin(-rad));
		nm.setData(2, 1, (float)Math.sin(rad));
		nm.setData(2, 2, (float)Math.cos(rad));
		
		multiplied(nm);
	}
	
	/* rotate by y */
	public void rotateByY(float degree) {
		float rad = degree * (float)Math.PI / 180.0f;
		
		Matrix4 nm = new Matrix4();
		nm.setData(0, 0, (float)Math.cos(rad));
		nm.setData(2, 0, (float)Math.sin(-rad));
		nm.setData(0, 2, (float)Math.sin(rad));
		nm.setData(2, 2, (float)Math.cos(rad));
		
		multiplied(nm);
	}
	
	/* rotate by z */
	public void rotateByZ(float degree) {
		float rad = degree * (float)Math.PI / 180.0f;
		
		Matrix4 nm = new Matrix4();
		nm.setData(0, 0, (float)Math.cos(rad));
		nm.setData(1, 1, (float)Math.sin(-rad));
		nm.setData(1, 0, (float)Math.sin(rad));
		nm.setData(0, 1, (float)Math.cos(rad));
		
		multiplied(nm);
	}
	
	@Override
	public String toString() {
		return
			data[0] + " " + data[1] + " " + data[2] + " " + data[3] + "\n" +
			data[4] + " " + data[5] + " " + data[6] + " " + data[7] + "\n" +
			data[8] + " " + data[9] + " " + data[10] + " " + data[11] + "\n" +
			data[12] + " " + data[13] + " " + data[14] + " " + data[15];
		
	}
}
