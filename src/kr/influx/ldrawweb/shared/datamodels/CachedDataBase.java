package kr.influx.ldrawweb.shared.datamodels;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import javax.persistence.Id;

import com.google.appengine.api.datastore.Blob;
import com.googlecode.objectify.annotation.Indexed;

abstract public class CachedDataBase<T> implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id Long id;
	@Indexed private Long fk;
	Blob data;
	
	public CachedDataBase(long foreignKey, T data) {
		id = null;
		fk = foreignKey;
		
		serializeData(data);
	}
	
	public long getKey() {
		return fk;
	}
	
	@SuppressWarnings("unchecked")
	public T getData() {
		return (T) deserializeData();
	}
	
	public void setKey(long foreignKey) {
		fk = foreignKey;
	}
	
	public void setCachedData(T data) {
		serializeData(data);
	}
	
	private void serializeData(T model) {
		ByteArrayOutputStream os = new ByteArrayOutputStream();
		ObjectOutputStream oos;
		try {
			oos = new ObjectOutputStream(os);
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}
		
		try {
			oos.writeObject(model);
			oos.flush();
			oos.close();
			os.close();
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}
		
		data = new Blob(os.toByteArray());
	}
	
	private Object deserializeData() {
		if (data == null)
			return null;
		
		ByteArrayInputStream is = new ByteArrayInputStream(data.getBytes());
		ObjectInputStream ois;
		try {
			ois = new ObjectInputStream(is);
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		
		try {
			return (Object) ois.readObject();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		
		return null;
	}
}
