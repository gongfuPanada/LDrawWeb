package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.ColorRgba;

public class Speckle extends BasicMaterial {
	private static final long serialVersionUID = 1L;
	
	private ColorRgba speckleColor;
	private float fraction;
	private float minsize;
	private float maxsize;
	
	public Speckle(int id, String name, ColorRgba color, ColorRgba edgecolor, ColorRgba speckleColor,
			float fraction, float minsize, float maxsize) {
		super(id, name, color, edgecolor);
		
		this.speckleColor = speckleColor;
		this.fraction = fraction;
		this.minsize = minsize;
		this.maxsize = maxsize;
	}
	
	public ColorRgba getSpeckleColor() {
		return speckleColor;
	}
	
	public float getFraction() {
		return fraction;
	}
	
	public float getMinimumSize() {
		return minsize;
	}
	
	public float getMaximumSize() {
		return maxsize;
	}
}
