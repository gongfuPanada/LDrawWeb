package kr.influx.ldrawweb.server;

import java.util.ArrayList;

import kr.influx.ldrawweb.client.SubmissionList;
import kr.influx.ldrawweb.shared.models.Model;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.googlecode.objectify.Query;

public class SubmissionListImpl extends RemoteServiceServlet implements
		SubmissionList {
	private static final long serialVersionUID = 5467706020329618102L;

	@Override
	public ArrayList<Model> getSubmissionList(int startOffset, int count) {
		DAO d = new DAO();
		
		ArrayList<Model> list = new ArrayList<Model>();
		
		Query<Model> qry = d.ofy().query(Model.class).offset(startOffset).limit(count);
		for (Model s : qry) {
			list.add(s);
		}
		
		return list;
	}
	
	@Override
	public ArrayList<Model> getSubmissionList(int startOffset, int count, String email) {
		DAO d = new DAO();
		
		ArrayList<Model> list = new ArrayList<Model>();
		
		Long id = new DAO().queryUser(email).getId();
		if (id == null)
			return list;
		
		Query<Model> qry = d.ofy().query(Model.class).offset(startOffset).limit(count);
		for (Model s : qry) {
			list.add(s);
		}
		
		return list;
	}

	@Override
	public void postSubmission(Model item) {
		DAO d = new DAO();
		
		d.ofy().put(item);
	}
}
