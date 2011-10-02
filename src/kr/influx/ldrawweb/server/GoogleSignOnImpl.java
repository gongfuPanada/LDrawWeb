package kr.influx.ldrawweb.server;

import kr.influx.ldrawweb.client.GoogleSignOn;
import kr.influx.ldrawweb.shared.GoogleSignOnInfo;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;

public class GoogleSignOnImpl extends RemoteServiceServlet implements
		GoogleSignOn {
	private static final long serialVersionUID = 2269436653035725559L;

	@Override
	public GoogleSignOnInfo signOn(String requestUri) {
		UserService us = UserServiceFactory.getUserService();
		User u = us.getCurrentUser();
		
		GoogleSignOnInfo so;
		if (u != null) {
			so = new GoogleSignOnInfo(u);
			so.setLogoutUrl(us.createLogoutURL(requestUri));
		} else {
			so = new GoogleSignOnInfo();
			so.setLoginUrl(us.createLoginURL(requestUri));
		}
		
		return so;
	}
}
