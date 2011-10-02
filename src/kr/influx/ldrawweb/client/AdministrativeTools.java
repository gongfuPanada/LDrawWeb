package kr.influx.ldrawweb.client;

import kr.influx.ldrawweb.shared.exceptions.NoAdministrativeRights;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("admin")
public interface AdministrativeTools extends RemoteService {
	public int rebuildDependencyGraph(int start, int count) throws NoAdministrativeRights;
	
	public void wipeAll() throws NoAdministrativeRights;
}
