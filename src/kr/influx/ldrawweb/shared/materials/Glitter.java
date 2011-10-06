package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.ColorRgba;

public class Glitter extends BasicMaterial {
	private static final long serialVersionUID = 1L;

	private ColorRgba glitterColor;
	private float hfraction;
	private float vfraction;
	private float size;
	
	public Glitter(int id, String name, ColorRgba color, ColorRgba edgecolor, ColorRgba glitterColor,
			float hfraction, float vfraction, float size) {
		super(id, name, color, edgecolor);
		
		this.glitterColor = glitterColor;
		this.hfraction = hfraction;
		this.vfraction = vfraction;
		this.size = size;
	}

	public ColorRgba getGlitterColor() {
		return glitterColor;
	}
	
	public float getHorizontalFraction() {
		return hfraction;
	}
	
	public float getVerticalFraction() {
		return vfraction;
	}
	
	public float getSize() {
		return size;
	}
}
