package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.LDrawMaterialBase;

public class EdgeColor extends LDrawMaterialBase {
	private static final long serialVersionUID = 1L;
	
	public EdgeColor() {
		super(24, "Default Color");
	}

	@Override
	public boolean isPredefined() {
		return true;
	}

}
