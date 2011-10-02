package kr.influx.ldrawweb.client;

import kr.influx.ldrawweb.shared.GoogleSignOnInfo;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("signon")
public interface GoogleSignOn extends RemoteService {
	public GoogleSignOnInfo signOn(String requestUri); 
}
