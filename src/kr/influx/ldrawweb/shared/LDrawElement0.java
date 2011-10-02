package kr.influx.ldrawweb.shared;

public class LDrawElement0 extends LDrawElementBase {
	private static final long serialVersionUID = 1L;
	
	private String comments;
	
	public LDrawElement0() {
		comments = "";
	}
	
	public LDrawElement0(String comments) {
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
