package kr.influx.ldrawweb.shared;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;

import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.exceptions.NoSuchItem;

public class DataBundle implements Serializable {
	private static final long serialVersionUID = 1L;

	private LDrawModelMultipart model;
	private HashMap<String, LDrawModel> parts;
	private HashSet<String> dependencies;
	private HashSet<String> marked;
	
	public DataBundle() {
		model = null;
		parts = new HashMap<String, LDrawModel>();
		dependencies = new HashSet<String>();
		marked = new HashSet<String>();
	}
	
	public LDrawModelMultipart getModel() {
		return model;
	}
	
	public void setModel(LDrawModelMultipart m) {
		model = m;
	}
	
	public HashMap<String, LDrawModel> getParts() {
		return parts;
	}
	
	public HashSet<String> getPendingDependencies() {
		return dependencies;
	}
	
	public void insertDependencies(LDrawModel m) {
		insertDependencies(m.getNormalizedName());
	}
	
	public void insertDependencies(Line1 e) {
		insertDependencies(e.getNormalizedPartId());
	}
	
	private void insertDependencies(String name) {
		if (parts.containsKey(name) || dependencies.contains(name))
			return;
		
		dependencies.add(name);
	}
	
	public void insertModel(LDrawModel m) {
		String name = m.getNormalizedName();
		
		marked.remove(name);
		
		parts.put(name, m);
	}
	
	public boolean isComplete() {
		return dependencies.size() == 0 && marked.size() == 0;
	}
	
	public boolean hasModel(LDrawModel m) {
		return parts.containsKey(m.getNormalizedName());
	}
	
	public boolean isLoaded(LDrawModel m) throws NoSuchItem {
		return isLoaded(m.getNormalizedName());
	}
	
	public boolean isLoaded(Line1 e) throws NoSuchItem {
		return isLoaded(e.getNormalizedPartId());
	}
	
	private boolean isLoaded(String name) throws NoSuchItem {
		if (!parts.containsKey(name) && !dependencies.contains(name))
			throw new NoSuchItem();
		
		if (parts.containsKey(name))
			return true;
		else
			return false;
	}
	
	public void invalidate(LDrawModel m) {
		invalidate(m.getNormalizedName());
	}
	
	public void invalidate(Line1 e) {
		invalidate(e.getNormalizedPartId());
	}
	
	public void invalidate(String name) {
		if (dependencies.contains(name))
			dependencies.remove(name);
		if (marked.contains(name))
			marked.remove(name);
	}
	
	public void mark(String name) {
		if (!dependencies.contains(name))
			return;
		
		dependencies.remove(name);
		marked.add(name);
	}
}
