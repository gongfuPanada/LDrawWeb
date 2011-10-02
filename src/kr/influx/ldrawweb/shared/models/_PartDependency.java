package kr.influx.ldrawweb.shared.models;

import java.io.Serializable;

import javax.persistence.Id;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity
public class _PartDependency implements Serializable {
	private static final long serialVersionUID = 5103109752276940018L;
	
	@Id private Long id;
	@Indexed private Integer type;
	@Indexed private Long fileid;
	private String filename;
	
	public _PartDependency() {
		id = 0L;
		type = 0;
		fileid = -1L;
		filename = null;
	}
	
	public _PartDependency(int type, long fileid, String filename) throws Exception {
		if (type != 0 && type != 1)
			throw new Exception("type parameter must be 0 or 1.");
		
		this.id = null;
		this.type = type;
		this.fileid = fileid;
		this.filename = filename;
	}
	
	public long getId() {
		return id;
	}
	
	public int getType() {
		return type;
	}
	
	public long getFileId() {
		return fileid;
	}
	
	public String getFilename() {
		return filename;
	}
	
	public void setId(long id) {
		this.id = id;
	}
	
	public void setType(int type) throws Throwable {
		if (type != 0 && type != 1)
			throw new Exception("type parameter must be 0 or 1.");
		
		this.type = type;
	}
	
	public void setFileId(long fileid) {
		this.fileid = fileid;
	}
	
	public void setFilename(String filename) {
		this.filename = filename;
	}
}
