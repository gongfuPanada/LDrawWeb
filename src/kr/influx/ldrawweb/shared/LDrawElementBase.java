package kr.influx.ldrawweb.shared;

import java.io.Serializable;

public abstract class LDrawElementBase implements Serializable {
	private static final long serialVersionUID = -6310662709974712744L;
	
	public LDrawElementBase() {}

	abstract public int lineType();
}
