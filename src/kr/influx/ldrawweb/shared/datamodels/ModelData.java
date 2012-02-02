package kr.influx.ldrawweb.shared.datamodels;

import kr.influx.ldrawweb.shared.LDrawModelMultipart;

import com.google.appengine.api.datastore.Blob;
import com.googlecode.objectify.annotation.Entity;

@Entity
public class ModelData extends RawDataBase<LDrawModelMultipart> {
	private static final long serialVersionUID = 1L;
	
	public ModelData() {
		super();
	}
	
	public ModelData(Blob data) {
		super(data);
	}
	
	public ModelData(long foreignKey, Blob data) {
		super(foreignKey, data);
	}
}

