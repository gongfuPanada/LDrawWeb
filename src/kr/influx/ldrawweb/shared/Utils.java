package kr.influx.ldrawweb.shared;

public class Utils {
	/* utility */
	static public String normalizeName(String filename) {
		String s = filename.trim().toLowerCase().replace('\\', '/');
		
		if (s.startsWith("s/"))
			return s.substring(2);
		else if (s.startsWith("48/"))
			return s.substring(3);
		
		return s;
	}
}
