package kr.influx.ldrawweb.shared.models;

import java.io.Serializable;

import javax.persistence.Id;

import com.google.appengine.api.datastore.Blob;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity
public class PartData implements Serializable {
	private static final long serialVersionUID = -5431171786053865193L;
	
	@Id Long id;
	@Indexed Long partId;
	Blob data;
	
	public PartData() {
		id = null;
	}
	
	public PartData(Blob data) {
		this.data = data;
	}

	public PartData(long partId, Blob data) {
		this.partId = partId;
		this.data = data;
	}
	
	/* getters */
	
	public Long getId() {
		return id;
	}
	
	public long getPartId() {
		return partId;
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
	
	public void setPartId(long partid) {
		this.partId = partid;
	}
	
	public void setData(Blob data) {
		this.data = data;
	}
}
