package kr.influx.ldrawweb.shared;

import java.io.Serializable;

public class ColorRgba implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private float color[];
	
	public ColorRgba() {
		this(0.0f, 0.0f, 0.0f, 1.0f);
	}
	
	public ColorRgba(float red, float green, float blue, float alpha) {
		color = new float[4];
		
		color[0] = red;
		color[1] = green;
		color[2] = blue;
		color[3] = alpha;
	}
	
	public ColorRgba(byte red, byte green, byte blue, byte alpha) {
		this(red / 255.0f, green / 255.0f, blue / 255.0f, alpha / 255.0f);
	}
	
	public ColorRgba(float red, float green, float blue) {
		this(red, green, blue, 1.0f);
	}
	
	public ColorRgba(byte red, byte green, float blue) {
		this(red / 255.0f, green / 255.0f, blue / 255.0f, 1.0f);
	}
	
	public float[] getArray() {
		return color;
	}
	
	public float getRed() {
		return color[0];
	}
	
	public float getGreen() {
		return color[1];
	}
	
	public float getBlue() {
		return color[2];
	}
	
	public float getAlpha() {
		return color[3];
	}
	
	public void setArray(float array[]) {
		if (array.length != 4)
			return;
		
		color[0] = array[0];
		color[1] = array[1];
		color[2] = array[2];
		color[3] = array[3];
	}
	
	public void setRed(float red) {
		color[0] = red;
	}
	
	public void setGreen(float green) {
		color[1] = green;
	}
	
	public void setBlue(float blue) {
		color[2] = blue;
	}
	
	public void setAlpha(float alpha) {
		color[3] = alpha;
	}
}
