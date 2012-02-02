package kr.influx.ldrawweb.server;

import kr.influx.ldrawweb.client.DataQuery;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.datamodels.Model;
import kr.influx.ldrawweb.shared.datamodels.ModelData;
import kr.influx.ldrawweb.shared.datamodels.ModelDataCached;
import kr.influx.ldrawweb.shared.datamodels.Part;
import kr.influx.ldrawweb.shared.datamodels.PartData;
import kr.influx.ldrawweb.shared.datamodels.PartDataCached;
import kr.influx.ldrawweb.shared.exceptions.NoSuchItem;

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
		
		ModelDataCached mc = dao.queryCachedModelData(m);
		if (mc != null)
			return mc.getData();
		
		ModelData md = dao.queryModelData(m);
		if (md == null)
			throw new NoSuchItem(new Long(id).toString());
		
		LDrawModelMultipart modelData = ServerUtils.parseMultipartModel(md.getData().getBytes());
		dao.insertModelCache(m, modelData);
		
		return modelData;
	}
	
	@Override
	public LDrawModel queryPart(String filename) throws NoSuchItem {
		Part p = dao.queryPart(filename);
		if (p == null)
			throw new NoSuchItem(filename);
		
		PartDataCached pc = dao.queryCachedPartData(p);
		if (pc != null)
			return pc.getData();
		
		PartData pd = dao.queryPartData(p);
		if (pd == null)
			throw new NoSuchItem(filename);
		
		LDrawModel partData = ServerUtils.parseModel(pd.getData().getBytes());
		dao.insertPartCache(p, partData);
		
		return partData;
	}
}
