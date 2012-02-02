package kr.influx.ldrawweb.shared.datamodels;

import com.googlecode.objectify.annotation.Entity;

import kr.influx.ldrawweb.shared.LDrawModelMultipart;

@Entity
public class ModelDataCached extends CachedDataBase<LDrawModelMultipart> {
	private static final long serialVersionUID = 1L;
	
	public ModelDataCached() {
		super();
	}
	
	public ModelDataCached(long foreignKey, LDrawModelMultipart data) {
		super(foreignKey, data);
	}
}
