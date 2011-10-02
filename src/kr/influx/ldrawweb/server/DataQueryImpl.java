package kr.influx.ldrawweb.server;

import kr.influx.ldrawweb.client.DataQuery;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.exceptions.NoSuchItem;
import kr.influx.ldrawweb.shared.models.Model;
import kr.influx.ldrawweb.shared.models.ModelData;
import kr.influx.ldrawweb.shared.models.Part;
import kr.influx.ldrawweb.shared.models.PartData;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;

public class DataQueryImpl extends RemoteServiceServlet implements DataQuery {
	private static final long serialVersionUID = 5024586302380486000L;

	final static private DAO dao;
	static {
		dao = new DAO();
	}
	
	@Override
	public void test() {
		/*
		Part p = dao.queryPart("3001.dat");
		PartData pd = dao.queryPartData(p);
		
		LDrawReader r = new LDrawReader(new ByteArrayInputStream(pd.getBytes()));
		try {
			r.parse(false);
		} catch (InvalidFileFormat e) {
			e.printStackTrace();
			
			System.out.println("error");
			
			return;
		}
		
		LDrawModel m = r.getModel();
		HashSet<String> names = resolveAll(m);
		
		for (String s : names)
			log.info(s);
			*/
	}
	
	@Override
	public LDrawModelMultipart queryModel(long id) throws NoSuchItem {
		Model m = dao.queryModel(id);
		if (m == null)
			throw new NoSuchItem(new Long(id).toString());
		
		ModelData md = dao.queryModelData(m);
		if (md == null)
			throw new NoSuchItem(new Long(id).toString());
		
		return ServerUtils.parseMultipartModel(md.getData().getBytes());
	}
	
	@Override
	public LDrawModel queryPart(String filename) throws NoSuchItem {
		Part m = dao.queryPart(filename);
		if (m == null)
			throw new NoSuchItem(filename);
		
		PartData md = dao.queryPartData(m);
		if (md == null)
			throw new NoSuchItem(filename);
		
		return ServerUtils.parseModel(md.getData().getBytes());
	}
}
