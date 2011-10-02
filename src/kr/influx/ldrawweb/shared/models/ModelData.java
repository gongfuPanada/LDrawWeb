package kr.influx.ldrawweb.shared.models;

import java.io.Serializable;

import javax.persistence.Id;

import com.google.appengine.api.datastore.Blob;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity
public class ModelData implements Serializable {
	private static final long serialVersionUID = -5431171786053865193L;
	
	@Id Long id;
	@Indexed Long submissionid;
	Blob data;
	Blob thumbnail;

	public ModelData() {
		id = null;
	}
	
	public ModelData(long submissionid, Blob data, Blob thumbnail) {
		this.submissionid = submissionid;
		this.data = data;
		this.thumbnail = thumbnail;
	}
	
	/* getters */
	
	public Long getId() {
		return id;
	}
	
	public long getSubmissionId() {
		return submissionid;
	}
	
	public Blob getData() {
		return data;
	}
	
	public Blob getThumbnail() {
		return thumbnail;
	}
	
	/* setters */
	
	public void setId(long id) {
		this.id = id;
	}
	
	public void setSubmissionId(long submissionid) {
		this.submissionid = submissionid;
	}
	
	public void setData(Blob data) {
		this.data = data;
	}
	
	public void setThumbnail(Blob thumbnail) {
		this.thumbnail = thumbnail;
	}
}
