package kr.influx.ldrawweb.shared;

/* line type 5 (optional line) */
public class LDrawElement5 extends LDrawElementBase {
	private static final long serialVersionUID = 2749942557910648283L;
	
	private int color;
	private Vector4 vec1;
	private Vector4 vec2;
	private Vector4 vec3;
	private Vector4 vec4;
	
	public LDrawElement5() {
		color = 0;
		vec1 = new Vector4();
		vec2 = new Vector4();
		vec3 = new Vector4();
		vec4 = new Vector4();
	}
	
	public LDrawElement5(int color, Vector4 vec1, Vector4 vec2, Vector4 vec3, Vector4 vec4) {
		this.color = color;
		this.vec1 = vec1;
		this.vec2 = vec2;
		this.vec3 = vec3;
		this.vec4 = vec4;
	}
	
	public int getColor() {
		return color;
	}
	
	public Vector4 getVec1() {
		return vec1;
	}
	
	public Vector4 getVec2() {
		return vec2;
	}
	
	public Vector4 getVec3() {
		return vec3;
	}
	
	public Vector4 getVec4() {
		return vec4;
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
	
	public void setVec3(Vector4 vec3) {
		this.vec3 = vec3;
	}
	
	public void setVec4(Vector4 vec4) {
		this.vec4 = vec4;
	}
	
	@Override
	public int lineType() {
		return 5;
	}
}
