package kr.influx.ldrawweb.client.renderer;

import com.google.gwt.core.client.GWT;
import com.google.gwt.resources.client.ClientBundle;
import com.google.gwt.resources.client.TextResource;

public interface Shaders extends ClientBundle {
	public static Shaders Instance = GWT.create(Shaders.class);
	
	@Source(value = {"fragment_default.txt"})
	TextResource defaultShaderFragment();
	
	@Source(value = {"vertex_default.txt"})
	TextResource defaultShaderVertex();
}
