package kr.influx.ldrawweb.shared.exceptions;

public class NotLoggedIn extends Exception {
	private static final long serialVersionUID = 1L;
	
	@Override
	public String toString() {
		return "Not logged in.";
	}
}
