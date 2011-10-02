package kr.influx.ldrawweb.client;

import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface DataQueryAsync {
	void test(AsyncCallback<Void> callback);

	void queryModel(long id, AsyncCallback<LDrawModelMultipart> callback);
	
	void queryPart(String filename, AsyncCallback<LDrawModel> callback);
}
