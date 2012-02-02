package kr.influx.ldrawweb.client.objects;

import com.google.gwt.core.client.JavaScriptObject;

public class ResponseObject extends JavaScriptObject {
	protected ResponseObject() {}
	
	public final native boolean getResult() /*- {
		return this.result;
	} -*/;
	
	public final native String getMessage() /*- {
		if (this.message)
			return this.message;
		else
			return "";
	} -*/;
}
