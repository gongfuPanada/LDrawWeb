package kr.influx.ldrawweb.client.meshgen;

import kr.influx.ldrawweb.shared.DataBundle;
import kr.influx.ldrawweb.shared.LDrawElementBase;
import kr.influx.ldrawweb.shared.LDrawModel;
import kr.influx.ldrawweb.shared.Matrix4;
import kr.influx.ldrawweb.shared.elements.Line1;
import kr.influx.ldrawweb.shared.elements.Line3;
import kr.influx.ldrawweb.shared.elements.Line4;
import kr.influx.ldrawweb.shared.materials.BasicMaterial;

public class Model {
	private boolean isValid;
	
	private VertexCloud vertices;
	private int count;
	
	public Model() {
		isValid = false;
		reset();
	}
	
	private void reset() {
		vertices = new VertexCloud();
	}
	
	public boolean isValid() {
		return isValid;
	}
	
	public void setMaterial(BasicMaterial material) {
		
	}
	
	private void flatternModelRecursive(DataBundle parent, Matrix4 globalMatrix, LDrawModel model, int depth, int depthBound) {
		for (LDrawElementBase elem : model) {
			if (elem instanceof Line3) {
				++count;
				
				Line3 triangle = (Line3) elem;
				vertices.put(globalMatrix.translate(triangle.getVec1()));
				vertices.put(globalMatrix.translate(triangle.getVec2()));
				vertices.put(globalMatrix.translate(triangle.getVec3()));
			} else if (elem instanceof Line4) {
				++count;
				
				Line4 quad = (Line4) elem;
				vertices.put(globalMatrix.translate(quad.getVec1()));
				vertices.put(globalMatrix.translate(quad.getVec2()));
				vertices.put(globalMatrix.translate(quad.getVec3()));
				vertices.put(globalMatrix.translate(quad.getVec4()));
			} else if (elem instanceof Line1) {
				Line1 ref = (Line1) elem;
				LDrawModel m = parent.findSubfile(((Line1) elem).getPartId());
				if (m != null) {
					if (depthBound == -1 || (depthBound != -1 && depth < depthBound)) {
						Matrix4 localMatrix = globalMatrix.multiply(ref.getMatrix());
						flatternModelRecursive(parent, localMatrix, m, depth + 1, depthBound);
					}
				}
			}
		}
	}
	
	public void process(DataBundle data, LDrawModel model, boolean dontTraverse) {
		count = 0;
		Matrix4 identityMatrix = new Matrix4();
		flatternModelRecursive(data, identityMatrix, model, 0, dontTraverse ? 0 : -1);
		
		if (count == 0) {
			isValid = false;
			return;
		}
		
		isValid = true;
		
		
	}
}
