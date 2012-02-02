package kr.influx.ldrawweb.shared.datamodels;

import java.io.Serializable;

import javax.persistence.Id;

import com.google.appengine.api.datastore.Blob;
import com.googlecode.objectify.annotation.Indexed;

abstract public class RawDataBase<T> implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id private Long id;
	@Indexed private Long fk;
	private Blob data;
	
	public RawDataBase() {
		id = null;
	}
	
	public RawDataBase(Blob data) {
		id = null;
		this.data = data;
	}

	public RawDataBase(long foreignKey, Blob data) {
		id = null;
		fk = foreignKey;
		this.data = data;
	}
	
	/* getters */
	
	public Long getId() {
		return id;
	}
	
	public long getKey() {
		return fk;
	}
	
	public Blob getData() {
		return data;
	}
	
	public byte[] getBytes() {
		return data.getBytes();
	}
	
	/* setters */
	
	public void setId(long id) {
		this.id = id;
	}
	
	public void setKey(long foreignKey) {
		fk = foreignKey;
	}
	
	public void setData(Blob data) {
		this.data = data;
	}
}
