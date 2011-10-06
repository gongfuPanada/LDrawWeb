package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.ColorRgba;

public class Solid extends BasicMaterial {
	private static final long serialVersionUID = 1L;
	
	public Solid(int id, String name, ColorRgba color, ColorRgba edgecolor) {
		super(id, name, color, edgecolor);
	}
}
