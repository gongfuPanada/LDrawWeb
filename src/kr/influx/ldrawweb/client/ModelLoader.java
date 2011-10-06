package kr.influx.ldrawweb.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.AsyncCallback;

import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.Utils;
import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.exceptions.NoSuchItem;

/* asynchronous, concurrent model loader/resolver */
public class ModelLoader {
	private int count = 0;   /* active queries */
	private int maxreqs = 5; /* maximum concurrent requests */
	private DataBundle bundle = null;
	private OnResult onresult = null;
	private DataQueryAsync rpc;
	
	public interface OnResult {
		public void onModelFailed(ModelLoader loader, String what);
		public void onModelLoaded(ModelLoader loader, LDrawModelMultipart model);
		public void onPartLoaded(ModelLoader loader, LDrawModel part);
		public void onPartFailed(ModelLoader loader, String partid);
		public void onComplete(ModelLoader loader);
	};
	
	private AsyncCallback<LDrawModelMultipart> modelLoader =
		new AsyncCallback<LDrawModelMultipart>() {
			@Override
			public void onFailure(Throwable caught) {
				if (caught instanceof NoSuchItem) {
					if (onresult != null)
						onresult.onModelFailed(ModelLoader.this, ((NoSuchItem)caught).getPartId());
				}
			}

			@Override
			public void onSuccess(LDrawModelMultipart result) {
				bundle = new DataBundle();
				bundle.setModel(result);
				
				if (onresult != null)
					onresult.onModelLoaded(ModelLoader.this, result);
				
				scanDependencies();
				advance();
			}
	};
	
	private AsyncCallback<LDrawModel> partLoader =
		new AsyncCallback<LDrawModel>() {
			@Override
			public void onFailure(Throwable caught) {
				if (caught instanceof NoSuchItem) {
					if (onresult != null)
						onresult.onPartFailed(ModelLoader.this, ((NoSuchItem)caught).getPartId());
				}
			}

			@Override
			public void onSuccess(LDrawModel result) {
				bundle = new DataBundle();
				bundle.setModel(new LDrawModelMultipart(result));
				
				scanDependencies();
				advance();
			}
	};
	
	private AsyncCallback<LDrawModel> partResolver =
		new AsyncCallback<LDrawModel>() {	
		@Override
		public void onFailure(Throwable caught) {
			if (caught instanceof NoSuchItem) {
				NoSuchItem i = (NoSuchItem)caught;
				
				if (i.getPartId() != null)
					bundle.invalidate(Utils.normalizeName(i.getPartId()));
				
				if (onresult != null)
					onresult.onPartFailed(ModelLoader.this, ((NoSuchItem)caught).getPartId());
				
				advance();
				
				--count;
			}
		}

		@Override
		public void onSuccess(LDrawModel result) {
			bundle.insertModel(result);
			
			if (onresult != null)
				onresult.onPartLoaded(ModelLoader.this, result);
			
			scanDependencies(result);
			advance();
			
			--count;
		}
	};
	
	public ModelLoader() {
		rpc = GWT.create(DataQuery.class);
	}
	
	public ModelLoader(int maxreqs, OnResult onresult) {
		this.maxreqs = maxreqs;
		this.onresult = onresult;
		
		rpc = GWT.create(DataQuery.class); 
	}
	
	public void start(int id) {
		rpc.queryModel(id, modelLoader);
	}
	
	public void start(String partid) {
		rpc.queryPart(partid, partLoader);
	}
	
	public DataBundle getBundle() {
		return bundle;
	}
	
	private void advance() {
		if (bundle == null)
			return;
		
		Object[] items = bundle.getPendingDependencies().toArray();
		
		for (int i = 0; i < maxreqs - count && i < items.length; ++i) {
			rpc.queryPart((String)items[i], partResolver);
			bundle.mark(Utils.normalizeName((String)items[i]));
			++count;
		}
		
		if (bundle.isComplete()) {
			if (onresult != null)
				onresult.onComplete(ModelLoader.this);
		}
	}
	
	private void scanDependencies() {
		scanDependencies(bundle.getModel().getMainModel());
		
		for (LDrawModel i : bundle.getModel().getSubpartList())
			scanDependencies(i);
	}
	
	private void scanDependencies(LDrawModel m) {
		for (LDrawElementBase i : m.getElements()) {
			if (i instanceof Line1)
				bundle.insertDependencies((Line1)i);
		}
	}
}
