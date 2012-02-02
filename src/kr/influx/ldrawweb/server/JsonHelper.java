package kr.influx.ldrawweb.server;

import java.io.IOException;
import java.io.OutputStreamWriter;

import javax.servlet.http.HttpServletResponse;

import com.google.appengine.repackaged.org.json.JSONException;
import com.google.appengine.repackaged.org.json.JSONObject;

public class JsonHelper {
	static public void writeToResponse(HttpServletResponse response, JSONObject object) {
		response.setContentType("application/json");
		
		try {
			OutputStreamWriter writer = new OutputStreamWriter(response.getOutputStream());
			writer.write(object.toString());
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	static public JSONObject getFailedResult(Throwable e) {
		JSONObject ret = new JSONObject();
		
		try {
			ret.put("result", false);
			ret.put("message", e.toString());
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
		
		return ret;
	}
	
	static public JSONObject getPositiveResult() {
		JSONObject ret = new JSONObject();
		
		try {
			ret.put("result", true);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		return ret;
	}
}
