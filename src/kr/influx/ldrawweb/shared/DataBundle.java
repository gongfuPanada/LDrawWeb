package kr.influx.ldrawweb.shared;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;

import kr.influx.ldrawweb.shared.exceptions.NoSuchItem;

public class DataBundle implements Serializable {
	private static final long serialVersionUID = 1L;

	private LDrawModelMultipart model;
	private HashMap<String, LDrawModel> parts;
	private HashSet<String> dependencies;
	private HashSet<String> inprogress;
	
	public DataBundle() {
		model = null;
		parts = new HashMap<String, LDrawModel>();
		dependencies = new HashSet<String>();
		inprogress = new HashSet<String>();
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
	
	public void insertDependencies(LDrawElement1 e) {
		insertDependencies(e.getNormalizedPartId());
	}
	
	private void insertDependencies(String name) {
		if (parts.containsKey(name) || dependencies.contains(name))
			return;
		
		dependencies.add(name);
	}
	
	public void insertModel(LDrawModel m) {
		String name = m.getNormalizedName();
		
		inprogress.remove(name);
		
		parts.put(name, m);
	}
	
	public boolean isComplete() {
		return dependencies.size() == 0 && inprogress.size() == 0;
	}
	
	public boolean hasModel(LDrawModel m) {
		return parts.containsKey(m.getNormalizedName());
	}
	
	public boolean isLoaded(LDrawModel m) throws NoSuchItem {
		return isLoaded(m.getNormalizedName());
	}
	
	public boolean isLoaded(LDrawElement1 e) throws NoSuchItem {
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
	
	public void invalidate(LDrawElement1 e) {
		invalidate(e.getNormalizedPartId());
	}
	
	public void invalidate(String name) {
		if (dependencies.contains(name))
			dependencies.remove(name);
		if (inprogress.contains(name))
			inprogress.remove(name);
	}
	
	public void check(String name) {
		if (!dependencies.contains(name))
			return;
		
		dependencies.remove(name);
		inprogress.add(name);
	}
}
