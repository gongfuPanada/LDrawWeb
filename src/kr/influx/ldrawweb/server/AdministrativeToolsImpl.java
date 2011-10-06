package kr.influx.ldrawweb.server;

import java.io.ByteArrayInputStream;
import java.util.HashSet;
import java.util.logging.Logger;

import kr.influx.ldrawweb.client.AdministrativeTools;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.datamodels.Part;
import kr.influx.ldrawweb.shared.datamodels.PartData;
import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.exceptions.InvalidFileFormat;
import kr.influx.ldrawweb.shared.exceptions.NoAdministrativeRights;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.googlecode.objectify.Objectify;

public class AdministrativeToolsImpl extends RemoteServiceServlet implements
		AdministrativeTools {
	private static final long serialVersionUID = -4957936360727219460L;
	
	private static final Logger log = Logger.getLogger(AdministrativeToolsImpl.class.getName());
	private static final DAO dao;
	static {
		dao = new DAO();
	}

	@Override
	public int rebuildDependencyGraph(int start, int count) throws NoAdministrativeRights {
		if (!ServerUtils.isAdministrator())
			throw new NoAdministrativeRights();
		
		Objectify ofy = dao.ofy();
		
		int ncnt = 0;		
		for (Part p : ofy.query(Part.class).offset(start).limit(count)) {
			PartData pd = dao.queryPartData(p);
			
			if (pd == null) {
				log.info("Part " + p.getName() + " has no part data.");
				
				continue;
			}
			
			ByteArrayInputStream bais = new ByteArrayInputStream(pd.getData().getBytes());
			LDrawReader r = new LDrawReader(bais);
			
			try {
				r.parse(false);
			} catch (InvalidFileFormat e) {
				log.info("Part " + p.getName() + " is invalid.");
				
				e.printStackTrace();
				continue;
			}
			
			HashSet<String> deps = new HashSet<String>();
			LDrawModel m = r.getModel();
			for (LDrawElementBase e : m.getElements()) {
				if (e instanceof Line1) {
					Line1 e1 = (Line1)e;
					
					deps.add(e1.getNormalizedPartId());
				}
			}
			
			if (deps.size() == 0) {
				log.info("Part " + p.getName() + " has no dependencies.");
				continue;
			} else {
				log.info("Part " + p.getName() + ": updated " + deps.size() + " dependencies.");
				++ncnt;
			}
		}
		
		return ncnt;
	}

	@Override
	public void wipeAll() throws NoAdministrativeRights {
		if (!ServerUtils.isAdministrator())
			throw new NoAdministrativeRights();
		
		dao.wipe();
	}
}
