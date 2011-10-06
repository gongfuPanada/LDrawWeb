package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.ColorRgba;
import kr.influx.ldrawweb.shared.LDrawMaterialBase;

public class BasicMaterial extends LDrawMaterialBase {
	private static final long serialVersionUID = 1L;
	
	protected ColorRgba color;
	protected ColorRgba edgecolor;
	

	public BasicMaterial(int id, String name, ColorRgba color, ColorRgba edgecolor) {
		super(id, name);
		
		this.color = color;
		this.edgecolor = edgecolor;
	}
	
	public ColorRgba getColor() {
		return color;
	}
	
	public ColorRgba getEdgeColor() {
		return edgecolor;
	}
	
	@Override
	public boolean isPredefined() {
		return false;
	}
}
