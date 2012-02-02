package kr.influx.ldrawweb.shared.datamodels;

import java.io.Serializable;

import javax.persistence.Id;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity
public class Part implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id private Long id;
	@Indexed private String partid;
	private String name;
	private String author;
	
	@Indexed private Long owner;
	
	public Part() {
		id = null;
		owner = -1L;
	}
	
	public Part(String partid, String name, String author, Long owner) {
		id = null;
		
		this.partid = partid;
		this.name = name;
		this.author = author;
		this.owner = owner;
	}
	
	/* getters */
	
	public Long getId() {
		return id;
	}
	
	public String getPartId() {
		return partid;
	}
	
	public String getName() {
		return name;
	}
	
	public String getAuthor() {
		return author;
	}
	
	public long getOwner() {
		return owner;
	}
	
	/* setters */
	
	public void setId(long id) {
		this.id = id;
	}
	
	public void setPartId(String partid) {
		this.partid = partid;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public void setAuthor(String author) {
		this.author = author;
	}
	
	public void setOwner(Long owner) {
		if (owner == null)
			this.owner = -1L;
		else
			this.owner = owner;
	}
}
