package kr.influx.ldrawweb.shared.elements;

import kr.influx.ldrawweb.shared.LDrawColorTable;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawMaterialBase;
import kr.influx.ldrawweb.shared.Vector4;

/* line type 2 (line) */
public class Line2 extends LDrawElementBase {
	private static final long serialVersionUID = 1868868646159265800L;
	
	private int color;
	private Vector4 vec1;
	private Vector4 vec2;
	
	public Line2() {
		color = 0;
		vec1 = new Vector4();
		vec2 = new Vector4();
	}
	
	public Line2(int color, Vector4 vec1, Vector4 vec2) {
		this.color = color;
		this.vec1 = vec1;
		this.vec2 = vec2;
	}
	
	public int getColor() {
		return color;
	}
	
	public LDrawMaterialBase getColorObject() {
		return LDrawColorTable.lookup(color);
	}
	
	public Vector4 getVec1() {
		return vec1;
	}
	
	public Vector4 getVec2() {
		return vec2;
	}
	
	public void setColor(int color) {
		this.color = color;
	}
	
	public void setVec1(Vector4 vec1) {
		this.vec1 = vec1;
	}
	
	public void setVec2(Vector4 vec2) {
		this.vec2 = vec2;
	}
	
	@Override
	public int lineType() {
		return 2;
	}
}
