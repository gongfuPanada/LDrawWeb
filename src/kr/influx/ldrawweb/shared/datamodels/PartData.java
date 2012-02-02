package kr.influx.ldrawweb.shared.datamodels;

import kr.influx.ldrawweb.shared.LDrawModel;

import com.google.appengine.api.datastore.Blob;
import com.googlecode.objectify.annotation.Entity;

@Entity
public class PartData extends RawDataBase<LDrawModel> {
	private static final long serialVersionUID = 1L;
	
	public long partId;

	public PartData() {
		super();
	}
	
	public PartData(Blob data) {
		super(data);
	}
	
	public PartData(long foreignKey, Blob data) {
		super(foreignKey, data);
	}
}
