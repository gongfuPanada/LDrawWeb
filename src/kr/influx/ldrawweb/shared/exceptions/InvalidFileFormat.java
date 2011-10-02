package kr.influx.ldrawweb.shared.exceptions;

public class InvalidFileFormat extends ReadError {
	private static final long serialVersionUID = -7888232396427624909L;
	
	private String line;
	
	public InvalidFileFormat(String line) {
		this.line = line;
	}
	
	@Override
	public String toString() {
		return "Invalid line: '" + line + "'";
	}
}
