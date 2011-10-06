package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.ColorRgba;

public class Transparent extends BasicMaterial {
	private static final long serialVersionUID = 1L;
	
	public Transparent(int id, String name, ColorRgba color, ColorRgba edgecolor) {
		super(id, name, color, edgecolor);
	}
}
