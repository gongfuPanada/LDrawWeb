package kr.influx.ldrawweb.shared.exceptions;

public class ReadError extends Exception {
	private static final long serialVersionUID = -6609406748267248642L;
	
	@Override
	public String toString() {
		return "Read error.";
	}
}
