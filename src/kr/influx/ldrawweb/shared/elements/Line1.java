package kr.influx.ldrawweb.shared.elements;

import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.Matrix4;
import kr.influx.ldrawweb.shared.Utils;

/* line type 1 (subfile inclusion) */
public class Line1 extends LDrawElementBase {
	private static final long serialVersionUID = 1L;
	
	private int color;
	private Matrix4 matrix;
	private String partid;
	
	public Line1() {
		color = 0;
		matrix = new Matrix4();
		partid = "";
	}
	
	public Line1(int color, Matrix4 matrix, String partid) {
		this.color = color;
		this.matrix = matrix;
		this.partid = partid;
	}
	
	public int getColor() {
		return color;
	}
	
	public Matrix4 getMatrix() {
		return matrix;
	}
	
	public String getPartId() {
		return partid;
	}
	
	public String getNormalizedPartId() {
		return Utils.normalizeName(partid);
	}
	
	public void setColor(int color) {
		this.color = color;
	}
	
	public void setMatrix(Matrix4 matrix) {
		this.matrix = matrix;
	}
	
	public void setPartId(String partid) {
		this.partid = partid;
	}
	
	@Override
	public int lineType() {
		return 1;
	}
	
	@Override
	public String toString() {
		return "1 " + color + " " + matrix + " " + partid;
	}
}
