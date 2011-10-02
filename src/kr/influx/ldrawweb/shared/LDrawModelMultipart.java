package kr.influx.ldrawweb.shared;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

public class LDrawModelMultipart implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private LDrawModel mainModel;
	private HashMap<String, LDrawModel> subparts;
	
	public LDrawModelMultipart() {
		mainModel = null;
		subparts = new HashMap<String, LDrawModel>();
	}
	
	public LDrawModelMultipart(LDrawModel mainModel) {
		this.mainModel = mainModel;
		subparts = new HashMap<String, LDrawModel>();
	}
	
	public LDrawModelMultipart(LDrawModel mainModel, HashMap<String, LDrawModel> subparts) {
		this.mainModel = mainModel;
		this.subparts = subparts;
	}
	
	public HashSet<String> getDependencies() {
		HashSet<String> set = new HashSet<String>();
		
		/* main model */
		for (LDrawElementBase e : mainModel.getElements()) {
			if (e instanceof LDrawElement1) {
				LDrawElement1 e1 = (LDrawElement1)e;
				
				String partid = e1.getNormalizedPartId();
				if (hasSubpart(partid))
					continue;
				set.add(partid);
			}
		}
		
		/* subparts */
		for (LDrawModel m : subparts.values()) {
			for (LDrawElementBase e : m.getElements()) {
				if (e instanceof LDrawElement1) {
					LDrawElement1 e1 = (LDrawElement1)e;
					
					String partid = e1.getNormalizedPartId();
					if (hasSubpart(partid))
						continue;
					set.add(partid);
				}
			}
		}
		
		return set;
	}
	
	public LDrawModel getMainModel() {
		return mainModel;
	}
	
	public ArrayList<LDrawModel> getSubpartList() {
		ArrayList<LDrawModel> a = new ArrayList<LDrawModel>();
		
		for (LDrawModel m : subparts.values())
			a.add(m);
		
		return a;
	}
	
	public LDrawModel querySubpart(String name) {
		return subparts.get(Utils.normalizeName(name));
	}
	
	public boolean hasSubpart(String name) {
		return subparts.containsKey(Utils.normalizeName(name));
	}
	
	public boolean putSubpart(LDrawModel model, boolean replace) {
		if (!replace && hasSubpart(model.getName()))
			return false;
		
		subparts.put(model.getNormalizedName(), model);
		
		return true;
	}
	
	public boolean putSubpart(String name, LDrawModel model, boolean replace) {
		if (!replace && hasSubpart(name))
			return false;
		
		subparts.put(Utils.normalizeName(name), model);
		
		return true;
	}
	
	public boolean removeSubpart(String name) {
		if (subparts.remove(Utils.normalizeName(name)) != null)
			return true;
		else
			return false;
	}
	
	public void setMainModel(LDrawModel model) {
		this.mainModel = model;
	}
}
