package kr.influx.ldrawweb.shared.exceptions;

public class NoSuchItem extends Exception {
	private static final long serialVersionUID = 1L;
	
	private String partid = null;
	
	public NoSuchItem() {
		
	}
	
	public NoSuchItem(String partid) {
		this.partid = partid;
	}
	
	public String getPartId() {
		return partid;
	}
}
