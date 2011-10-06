package kr.influx.ldrawweb.server;

import kr.influx.ldrawweb.shared.datamodels.Account;
import kr.influx.ldrawweb.shared.datamodels.Model;
import kr.influx.ldrawweb.shared.datamodels.ModelData;
import kr.influx.ldrawweb.shared.datamodels.Part;
import kr.influx.ldrawweb.shared.datamodels.PartData;

import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.Query;
import com.googlecode.objectify.util.DAOBase;

public class DAO extends DAOBase {
	static {
		ObjectifyService.register(Model.class);
		ObjectifyService.register(ModelData.class);
		ObjectifyService.register(Part.class);
		ObjectifyService.register(PartData.class);
		ObjectifyService.register(Account.class);
	}
	
	public void wipe() {
		ofy().delete(ofy().query(Part.class));
		ofy().delete(ofy().query(PartData.class));
	}
	
	public Account queryUser(String email) {
		Query<Account> q = ofy().query(Account.class).filter("email", email);
		
		if (q.count() == 0)
			return null;
		
		return q.iterator().next();
	}
	
	public Model queryModel(long id) {
		Query<Model> model = ofy().query(Model.class).filter("id", id);
		
		if (model.count() == 0)
			return null;
		
		return model.iterator().next();
	}
	
	public ModelData queryModelData(Model m) {
		if (m.getId() == null)
			return null;
		
		Query<ModelData> modeldata = ofy().query(ModelData.class).filter("submissionid", m.getId());
		
		if (modeldata.count() == 0)
			return null;
		
		return modeldata.iterator().next();
	}
	
	public Part queryPart(String name) {
		Query<Part> part = ofy().query(Part.class).filter("owner", -1L).filter("partid", name);
		
		if (part.count() == 0)
			return null;
		
		return part.iterator().next();
	}
	
	public Part queryPart(String name, String owner) {
		Account acnt = queryUser(owner);
		if (acnt == null)
			return null;
		
		Query<Part> part = ofy().query(Part.class).filter("owner", acnt.getId()).filter("partid", name);
		
		if (part.count() == 0)
			return null;
		
		return part.iterator().next();
	}
	
	public PartData queryPartData(Part p) {
		if (p.getId() == null)
			return null;
		
		Query<PartData> partdata = ofy().query(PartData.class).filter("partId", p.getId());
		
		if (partdata.count() == 0)
			return null;
		
		return partdata.iterator().next();
	}
	
	public boolean insertPart(Part p, PartData d) {
		Objectify ofy = ofy();
		
		try {
			Part px = queryPart(p.getPartId());
			ofy.delete(ofy.query(PartData.class).filter("partid", px.getId()));
			ofy.delete(px);
		} catch (Exception e) {}
		
		long id = ofy.put(p).getId();
		p.setId(id);
		d.setPartId(id);
		d.setId(ofy.put(d).getId());
		
		return true;
	}
}
