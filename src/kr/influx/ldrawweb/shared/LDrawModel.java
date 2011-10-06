package kr.influx.ldrawweb.shared;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;

import kr.influx.ldrawweb.shared.elements.Line1;

public class LDrawModel implements Serializable, Iterable<LDrawElementBase> {
	private static final long serialVersionUID = 1L;
	
	private String name;
	private String author;
	private String description;
	private ArrayList<LDrawElementBase> elements;
	
	public LDrawModel() {
		name = null;
		author = null;
		description = null;
		elements = new ArrayList<LDrawElementBase>();
	}
	
	public LDrawModel(String name, String author, String description, ArrayList<LDrawElementBase> elements) {
		this.name = name;
		this.author = author;
		this.description = description;
		this.elements = elements;
	}
	
	@Override
	public Iterator<LDrawElementBase> iterator() {
		return elements.iterator();
	}
	
	public HashSet<String> getDependencies() {
		HashSet<String> set = new HashSet<String>();
		
		for (LDrawElementBase e : elements) {
			if (e instanceof Line1) {
				Line1 e1 = (Line1)e;
				set.add(e1.getNormalizedPartId());
			}
		}
		
		return set;
	}
	
	/* getters */
	
	public String getName() {
		return name;
	}
	
	public String getNormalizedName() {
		return Utils.normalizeName(name);
	}
	
	public String getAuthor() {
		return author;
	}
	
	public String getDescription() {
		return description;
	}
	
	public ArrayList<LDrawElementBase> getElements() {
		return elements;
	}
	
	/* setters */
	
	public void setName(String name) {
		this.name = name;
	}
	
	public void setAuthor(String author) {
		this.author = author;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}
	
	public void setElements(ArrayList<LDrawElementBase> elements) {
		this.elements = elements;
	}
}
