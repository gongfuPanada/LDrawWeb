package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.ColorRgba;

public class Milky extends BasicMaterial {
	private static final long serialVersionUID = 1L;

	private float luminance;
	
	public Milky(int id, String name, ColorRgba color, ColorRgba edgecolor, float luminance) {
		super(id, name, color, edgecolor);
		
		this.luminance = luminance;
	}
	
	public float getLuminance() {
		return luminance;
	}
}
