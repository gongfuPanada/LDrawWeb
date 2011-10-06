package kr.influx.ldrawweb.shared;

import java.io.Serializable;

public abstract class LDrawMaterialBase implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private int id;
	private String name;
	
	public LDrawMaterialBase(int id, String name) {
		this.id = id;
		this.name = name;
	}

	public int getId() {
		return id;
	}
	
	public String getName() {
		return name;
	}
	
	abstract public boolean isPredefined();
}
