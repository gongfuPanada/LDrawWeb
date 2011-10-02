package kr.influx.ldrawweb.client;

import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.exceptions.NoSuchItem;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("data")
public interface DataQuery extends RemoteService {
	public void test();
	
	public LDrawModelMultipart queryModel(long id) throws NoSuchItem;
	
	public LDrawModel queryPart(String filename) throws NoSuchItem;
}
