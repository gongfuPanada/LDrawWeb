package kr.influx.ldrawweb.shared.exceptions;

public class SizeLimitExceeded extends ReadError {
	private static final long serialVersionUID = -2807362128251967000L;
	
	@Override
	public String toString() {
		return "Upload size limit exceeded.";
	}
}
