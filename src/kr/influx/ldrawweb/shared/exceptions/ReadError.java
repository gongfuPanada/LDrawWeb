package kr.influx.ldrawweb.shared.exceptions;

public class ReadError extends Exception {
	private static final long serialVersionUID = 1L;
	
	@Override
	public String toString() {
		return "Read error.";
	}
}
