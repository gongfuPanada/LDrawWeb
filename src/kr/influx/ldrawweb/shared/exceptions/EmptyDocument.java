package kr.influx.ldrawweb.shared.exceptions;

public class EmptyDocument extends ReadError {
	private static final long serialVersionUID = 3021865118081034223L;
	
	@Override
	public String toString() {
		return "Document is empty.";
	}
}
