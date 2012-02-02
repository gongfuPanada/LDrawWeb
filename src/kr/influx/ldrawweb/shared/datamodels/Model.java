package kr.influx.ldrawweb.shared.datamodels;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Id;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity
public class Model implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id private Long id;
	
	@Indexed private Long owner;
	
	private Date submissionDate;
	private Date lastModified;
	
	private String name;
	private String author;
	private String filename;
	
	private String description;
	
	public Model() {
		id = null;
	}
	
	public Model(long owner, Date date, String name,
			String author, String filename, String description) {
		id = null;
		
		this.owner = owner;
		this.submissionDate = date;
		this.lastModified = date;
		this.name = name;
		this.author = author;
		this.filename = filename;
		this.description = description;
	}
	
	/* getters */
	
	public Long getId() {
		return id;
	}
	
	public long getOwner() {
		return owner;
	}
	
	public Date getSubmissionDate() {
		return submissionDate;
	}
	
	public Date getLastModifiedDate() {
		return lastModified;
	}
	
	public String getName() {
		return name;
	}
	
	public String getAuthor() {
		return author;
	}
	
	public String getFilename() {
		return filename;
	}
	
	public String getDescription() {
		return description;
	}
	
	/* setters */
	
	public void setId(long id) {
		this.id = id;
	}
	
	public void setOwner(long user) {
		this.owner = user;
	}
	
	public void setSubmissionDate(Date date) {
		this.submissionDate = date;
	}
	
	public void setLastModifiedDate(Date lastModified) {
		this.lastModified = lastModified;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public void setAuthor(String author) {
		this.author = author;
	}
	
	public void setFilename(String filename) {
		this.filename = filename;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}
}
