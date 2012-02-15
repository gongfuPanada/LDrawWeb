package kr.influx.ldrawweb.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.AsyncCallback;

import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.DependencyResolver;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.LDrawModelMultipart;
import kr.influx.ldrawweb.shared.exceptions.NoSuchItem;

/* asynchronous, concurrent model loader/resolver */
public class ClientDependencyResolver extends DependencyResolver {
	private int count = 0;   /* active queries */
	private int maxreqs = 5; /* maximum concurrent requests */
	private DataQueryAsync rpc;
	
	private AsyncCallback<LDrawModelMultipart> modelLoader =
		new AsyncCallback<LDrawModelMultipart>() {
			@Override
			public void onFailure(Throwable caught) {
				if (caught instanceof NoSuchItem) {
					if (onresult != null)
						onresult.onModelFailed(ClientDependencyResolver.this, ((NoSuchItem)caught).getPartId());
				}
			}

			@Override
			public void onSuccess(LDrawModelMultipart result) {
				bundle = new DataBundle();
				bundle.setModel(result);
				
				if (onresult != null)
					onresult.onModelLoaded(ClientDependencyResolver.this, result);
				
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
						onresult.onPartFailed(ClientDependencyResolver.this, ((NoSuchItem)caught).getPartId());
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
					bundle.invalidate(i.getPartId());
				
				if (onresult != null)
					onresult.onPartFailed(ClientDependencyResolver.this, ((NoSuchItem)caught).getPartId());
				
				advance();
				
				--count;
			}
		}

		@Override
		public void onSuccess(LDrawModel result) {
			bundle.insertModel(result);
			
			if (onresult != null)
				onresult.onPartLoaded(ClientDependencyResolver.this, result);
			
			scanDependencies(result);
			advance();
			
			--count;
		}
	};
	
	public ClientDependencyResolver() {
		super();
		rpc = GWT.create(DataQuery.class);
	}
	
	public ClientDependencyResolver(int maxreqs, OnResult onresult) {
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
	
	@Override
	protected void queryNext(String[] pendingDependencies) {
		for (int i = 0; i < maxreqs - count && i < pendingDependencies.length; ++i) {
			rpc.queryPart(pendingDependencies[i], partResolver);
			bundle.mark(pendingDependencies[i]);
			++count;
		}
	}
}
