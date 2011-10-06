package kr.influx.ldrawweb.shared.materials;

import kr.influx.ldrawweb.shared.LDrawMaterialBase;

public class DefaultColor extends LDrawMaterialBase {
	private static final long serialVersionUID = 1L;
	
	public DefaultColor() {
		super(16, "Default Color");
	}

	@Override
	public boolean isPredefined() {
		return true;
	}

}
