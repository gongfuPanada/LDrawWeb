package kr.influx.ldrawweb.client;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface AdministrativeToolsAsync {
	public void rebuildDependencyGraph(int start, int count, AsyncCallback<Integer> callback);

	void wipeAll(AsyncCallback<Void> callback);
}
