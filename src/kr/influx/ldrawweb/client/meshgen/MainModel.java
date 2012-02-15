package kr.influx.ldrawweb.client.meshgen;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.Matrix4;
import kr.influx.ldrawweb.shared.Utils;
import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.elements.Line3;
import kr.influx.ldrawweb.shared.elements.Line4;
import kr.influx.ldrawweb.shared.elements.MetaStep;

public class MainModel {
	static public class RenderingUnit {
		public Line1 metadata;
		public Model data;
		
		public RenderingUnit(Model m) {
			metadata = new Line1();
			data = m;
		}
		
		public RenderingUnit(Line1 metadata, Model data) {
			this.metadata = metadata;
			this.data = data;
		}
	};
	
	static public class RenderingList extends ArrayList<RenderingUnit> {
		private static final long serialVersionUID = 1L;

		public RenderingList() {
			super();
		}
	};
	
	static public class RenderingSteps extends ArrayList<RenderingList> {
		private static final long serialVersionUID = 1L;
		
		private RenderingList last;
		
		public RenderingSteps() {
			super();
			
			nextStep();
		}
		
		public RenderingList currentStep() {
			return last;
		}
		
		public RenderingList nextStep() {
			if (last != null && last.size() == 0)
				return last;
			
			last = new RenderingList();
			add(last);
			
			return last;
		}
		
		public Iterator<RenderingList> scopedIterator(final int lowerBound, final int upperBound) {
			return new Iterator<RenderingList>() {
				int ptr = lowerBound;
				
				@Override
				public boolean hasNext() {
					if (ptr >= upperBound || ptr >= size())
						return false;
					
					return true;
				}

				@Override
				public RenderingList next() {
					return get(ptr++);
				}

				@Override
				public void remove() {
					/* this method is not supported */
				}
			};
		}
		
		public Iterator<RenderingList> scopedIterator(final int lowerBound) {
			return new Iterator<RenderingList>() {
				int ptr = lowerBound;
				
				@Override
				public boolean hasNext() {
					if (ptr >= size())
						return false;
					
					return true;
				}

				@Override
				public RenderingList next() {
					return get(ptr++);
				}

				@Override
				public void remove() {
					/* this method is not supported */
				}
			};
		}
	};
	
	private Set<String> marked;
	private Map<String, Model> parts;
	private Map<String, Model> uncollapsedModel;
	
	private RenderingSteps steps;
	
	/* intermediate states */
	
	public MainModel() {
		marked = null;
		parts = null;
		uncollapsedModel = null;
		steps = null;
	}
	
	private void traverseModel(DataBundle parent, LDrawModel m, int depth, Matrix4 modelview, boolean ignoreSteps) {
		RenderingList cur = steps.currentStep();
		
		System.out.println("depth " + depth);
		
		for (LDrawElementBase e : m) {
			if (e instanceof MetaStep) {
				if (!ignoreSteps) {
					cur = steps.nextStep();
				}
			} else if (e instanceof Line1) {
				Line1 i = (Line1) e;
				String normalizedName = Utils.normalizeName(i.getPartId());
				
				LDrawModel submodel = parent.getModel().querySubpart(normalizedName);
				if (submodel != null) {
					/* multipart */
					if (marked.contains(normalizedName))
						ignoreSteps = true;
					else
						marked.add(normalizedName);
					
					Matrix4 translated = modelview.multiply(i.getMatrix());
					traverseModel(parent, submodel, depth + 1, translated, ignoreSteps);
				} else {
					LDrawModel em = parent.findSubfile(i.getPartId());
					
					if (em != null) {
						if (parts.containsKey(normalizedName)) {
							cur.add(new RenderingUnit(i, parts.get(normalizedName)));
						} else {
							/* request for build */
							
							Model nm = new Model();
							/* FIXME: isolate from core logic in order to prevent UI lockup. */
							nm.process(parent, em, false);
							
							if (nm.isValid()) {
								parts.put(normalizedName, nm);
								cur.add(new RenderingUnit(i, nm));
							}
						}
					}
				}
			} else if (e instanceof Line3 || e instanceof Line4) {
				String name;
				if (depth > 0)
					name = m.getName();
				else
					name = "";
				
				Model nm = new Model();
				nm.process(parent, m, true);
				
				if (nm.isValid()) {
					uncollapsedModel.put(name, nm);
					cur.add(new RenderingUnit(new Line1(0, modelview, null), nm));
				}
			}
		}
	}
	
	public void build(DataBundle data) {
		marked = new HashSet<String>();
		parts = new HashMap<String, Model>();
		uncollapsedModel = new HashMap<String, Model>();
		steps = new RenderingSteps();
		
		Matrix4 identity = new Matrix4();
		traverseModel(data, data.getModel().getMainModel(), 0, identity, false);
		
		if (steps.currentStep().size() == 0)
			steps.remove(steps.currentStep());
		
		int i = 0;
		for (RenderingList l : steps) {
			System.out.println("step " + (i++) + ": " + l.size());
		}
	}
}
