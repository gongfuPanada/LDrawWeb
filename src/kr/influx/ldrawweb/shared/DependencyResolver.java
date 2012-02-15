package kr.influx.ldrawweb.shared;

import java.util.Set;

import kr.influx.ldrawweb.shared.elements.Line1;

abstract public class DependencyResolver {
	protected DataBundle bundle = null;
	protected OnResult onresult = null;
	
	public interface OnResult {
		public void onModelFailed(DependencyResolver loader, String what);
		public void onModelLoaded(DependencyResolver loader, LDrawModelMultipart model);
		public void onPartLoaded(DependencyResolver loader, LDrawModel part);
		public void onPartFailed(DependencyResolver loader, String partid);
		public void onComplete(DependencyResolver loader, DataBundle bundle);
	};
	
	public DependencyResolver() {
		bundle = null;
		onresult = null;
	}
	
	public DependencyResolver(OnResult onresult) {
		bundle = null;
		this.onresult = onresult; 
	}
	
	protected void advance() {
		if (bundle == null || bundle.isComplete())
			return;
		
		Set<String> items = bundle.getPendingDependencies();
		String[] itemArray = new String[items.size()];
		int i = 0;
		for (String s : items)
			itemArray[i++] = s;
		
		queryNext(itemArray);
		
		if (bundle.isComplete()) {
			if (onresult != null)
				onresult.onComplete(this, bundle);
		}
	}
	
	protected void scanDependencies() {
		scanDependencies(bundle.getModel().getMainModel());
		
		for (LDrawModel i : bundle.getModel().getSubpartList())
			scanDependencies(i);
	}
	
	protected void scanDependencies(LDrawModel m) {
		for (LDrawElementBase i : m.getElements()) {
			if (i instanceof Line1)
				bundle.insertDependencies((Line1)i);
		}
	}
	
	abstract protected void queryNext(String[] pendingDependencies);
}
