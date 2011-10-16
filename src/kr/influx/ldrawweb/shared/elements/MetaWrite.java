package kr.influx.ldrawweb.shared.elements;

public class MetaWrite extends MetaCommandBase {
	private static final long serialVersionUID = 1L;
	
	private String message;

	public MetaWrite(String message) {
		this.message = message;
		
		updateLine();
	}
	
	public String getMessage() {
		return message;
	}
	
	public void setMessage(String message) {
		this.message = message;
		
		updateLine();
	}
	
	@Override
	protected void updateLine() {
		setMessage("WRITE " + message);
	}
}
