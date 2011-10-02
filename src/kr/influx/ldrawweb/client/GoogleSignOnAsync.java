package kr.influx.ldrawweb.client;

import kr.influx.ldrawweb.shared.GoogleSignOnInfo;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface GoogleSignOnAsync {
	public void signOn(String requestUri, AsyncCallback<GoogleSignOnInfo> callback);
}
