package kr.influx.ldrawweb.shared.elements;

import kr.influx.ldrawweb.shared.LDrawElementBase;

public class Line0 extends LDrawElementBase {
	private static final long serialVersionUID = 1L;
	
	private String comments;
	
	public Line0() {
		comments = "";
	}
	
	public Line0(String comments) {
		this.comments = comments;
	}
	
	public String getString() {
		return comments;
	}
	
	public void setString(String s) {
		comments = s;
	}
	
	@Override
	public int lineType() {
		return 0;
	}
	
	@Override
	public String toString() {
		return "0 " + comments;
	}
}
