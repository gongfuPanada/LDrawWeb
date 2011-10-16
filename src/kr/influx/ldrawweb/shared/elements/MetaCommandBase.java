package kr.influx.ldrawweb.shared.elements;

public abstract class MetaCommandBase extends Line0 {
	private static final long serialVersionUID = 1L;
	
	public MetaCommandBase() {
		super("");
	}
	
	public MetaCommandBase(String commandLine) {
		super(commandLine);
	}
	
	protected void updateLine() {	
	}
}
