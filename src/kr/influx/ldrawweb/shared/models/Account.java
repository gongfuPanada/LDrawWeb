package kr.influx.ldrawweb.shared.models;

import java.io.Serializable;

import javax.persistence.Id;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Indexed;

@Entity
public class Account implements Serializable {
	private static final long serialVersionUID = -6262755534835694662L;

	@Id private Long id;
	@Indexed private String email;
	
	private String name;
	private String website;
	
	public Account() {
		id = null;
	}
	
	public Account(String user, String name, String website) {
		this.email = user;
		this.name = name;
		this.website = website;
	}
	
	public Account(User user, String name, String website) {
		this.email = user.getEmail();
		this.name = name;
		this.website = website;
	}
	
	/* getters */
	
	public long getId() {
		return id;
	}
	
	public String getEmail() {
		return email;
	}
	
	public String getName() {
		return name;
	}
	
	public String getWebsite() {
		return website;
	}
	
	/* setters */
	
	public void setId(long id) {
		this.id = id;
	}
	
	public void setEmail(String email){
		this.email = email;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public void setWebsite(String website) {
		this.website = website;
	}
}
