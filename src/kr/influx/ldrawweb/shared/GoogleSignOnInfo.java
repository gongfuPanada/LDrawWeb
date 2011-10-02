package kr.influx.ldrawweb.shared;

import java.io.Serializable;

import com.google.appengine.api.users.User;

public class GoogleSignOnInfo implements Serializable {
	private static final long serialVersionUID = 1L;
	
	boolean loggedIn = false;
	String loginUrl;
	String logoutUrl;
	String email;
	String nickname;
	
	public GoogleSignOnInfo(User u) {
		loggedIn = true;
		email = u.getEmail();
		loginUrl = u.getNickname();
	}
	
	public GoogleSignOnInfo() {
		loggedIn = false;
	}
	
	/* getters */
	
	public boolean isLoggedIn() {
		return loggedIn;
	}
	
	public String getLoginUrl() {
		return loginUrl;
	}
	
	public String getLogoutUrl() {
		return logoutUrl;
	}
	
	public String getEmail() {
		return email;
	}
	
	public String getNickname() {
		return nickname;
	}
	
	/* setters */
	
	public void setLoggedIn(boolean loggedIn) {
		this.loggedIn = loggedIn; 
	}
	
	public void setLoginUrl(String url) {
		this.loginUrl = url;
	}
	
	public void setLogoutUrl(String url) {
		this.logoutUrl = url;
	}
	
	public void setEmail(String email) {
		this.email = email;
	}
	
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
}
