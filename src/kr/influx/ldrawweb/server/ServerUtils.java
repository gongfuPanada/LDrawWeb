package kr.influx.ldrawweb.server;

import java.io.ByteArrayInputStream;

import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.datamodels.Part;
import kr.influx.ldrawweb.shared.datamodels.PartData;
import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.exceptions.InvalidFileFormat;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;

public class ServerUtils {
	static public boolean isSignedOn() {
		User u = UserServiceFactory.getUserService().getCurrentUser();
		
		if (u == null)
			return false;
		else
			return true;
	}
	
	static public boolean isAdministrator() {
		final String ADMINISTRATOR = "segfault87@gmail.com";
		
		User u = UserServiceFactory.getUserService().getCurrentUser();
		
		if (u == null)
			return false;
		else if (u.getEmail().equals(ADMINISTRATOR))
			return true;
		else
			return false;
	}
	
	static public LDrawModel getPartData(Line1 e) {
		DAO dao = new DAO();
		
		Part p = dao.queryPart(e.getNormalizedPartId());
		if (p == null)
			return null;
		
		PartData pd = dao.queryPartData(p);
		if (pd == null)
			return null;
		
		return parseModel(pd.getData().getBytes());
	}
	
	static public LDrawModel parseModel(byte[] data) {
		return readModel(data).getModel();
	}
	
	static public LDrawModelMultipart parseMultipartModel(byte[] data) {
		return readModel(data).getMultipartModel();
	}
	
	static private LDrawReader readModel(byte[] data) {
		LDrawReader reader = new LDrawReader(new ByteArrayInputStream(data));
		try {
			reader.parse(false);
		} catch (InvalidFileFormat _) {
			_.printStackTrace();
			return null;
		}
		
		return reader;
	}
}
