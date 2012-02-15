package kr.influx.ldrawweb.tests;

import java.io.File;
import java.io.FileInputStream;

import kr.influx.ldrawweb.server.LDrawReader;
import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.DependencyResolver;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.Utils;

public class LocalResolver extends DependencyResolver {
	static final private String LDRAW_PATH = "/usr/share/_ldraw";
	
	static final private String LDRAW_PARTS = "parts";
	static final private String LDRAW_SUBPARTS = "parts/s";
	static final private String LDRAW_PRIMS = "p";
	static final private String LDRAW_PRIMS_48 = "p/48";
	
	private String ldrawDir;
	
	public LocalResolver(DependencyResolver.OnResult result) {
		super(result);
		
		ldrawDir = LDRAW_PATH;
	}
	
	public LocalResolver(String path, DependencyResolver.OnResult result) {
		super(result);
		
		ldrawDir = path;
	}
	
	private String guessSubpart(String filename) {
		String normalized = Utils.normalizeName(filename);
		
		File f = new File(ldrawDir + "/" + LDRAW_PARTS + "/" + normalized);
		if (f.exists())
			return f.getAbsolutePath();
		
		f = new File(ldrawDir + "/" + LDRAW_PRIMS + "/" + normalized);
		if (f.exists())
			return f.getAbsolutePath();
		
		f = new File(ldrawDir + "/" + LDRAW_SUBPARTS + "/" + normalized);
		if (f.exists())
			return f.getAbsolutePath();
		
		f = new File(ldrawDir + "/" + LDRAW_PRIMS_48 + "/" + normalized);
		if (f.exists())
			return f.getAbsolutePath();
		
		return null;
	}
	
	@Override
	protected void queryNext(String[] pendingDependencies) {
		for (String fn : pendingDependencies) {
			String path = guessSubpart(fn);
			
			bundle.mark(fn);
			
			if (path != null) {
				LDrawReader reader;
				try {
					reader = new LDrawReader(new FileInputStream(path));
					reader.parse(false);
				} catch (Throwable e) {
					e.printStackTrace();
					bundle.invalidate(fn);
					onresult.onPartFailed(this, fn);
					continue;
				}
				
				LDrawModel m = reader.getModel();
				bundle.insertModel(m);
				onresult.onPartLoaded(this, m);
				
				scanDependencies(m);
			} else {
				bundle.invalidate(fn);
				onresult.onPartFailed(this, fn);
			}
		}
	}
	
	public void start(String filename) {
		try {
			LDrawReader reader = new LDrawReader(new FileInputStream(filename));
			reader.parse(false);
		
			bundle = new DataBundle();
			LDrawModelMultipart model = reader.getMultipartModel();
			bundle.setModel(model);
			onresult.onModelLoaded(this, model);
		
			scanDependencies();
			advance();
		} catch (Throwable e) {
			e.printStackTrace();
			onresult.onModelFailed(this, filename);
		}
	}
	
	public void readUntilDone() {
		if (bundle == null)
			return;
		
		while (!bundle.isComplete())
			advance();
	}
}
