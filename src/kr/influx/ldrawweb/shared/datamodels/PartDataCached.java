package kr.influx.ldrawweb.shared.datamodels;

import com.googlecode.objectify.annotation.Entity;

import kr.influx.ldrawweb.shared.LDrawModel;

@Entity
public class PartDataCached extends CachedDataBase<LDrawModel> {
	private static final long serialVersionUID = 1L;
	
	public PartDataCached(long foreignKey, LDrawModel data) {
		super(foreignKey, data);
	}
}
