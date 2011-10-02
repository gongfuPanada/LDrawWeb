/**   
 * Copyright 2010 Sönke Sothmann, Steffen Schäfer and others
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.googlecode.gwtgl.binding;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * @author Steffen Schäfer
 * 
 */
public final class WebGLContextAttributes extends JavaScriptObject {
	/**
	 * protected standard constructor for the JavaScriptObject.
	 */
	protected WebGLContextAttributes() {
		super();
	}

	/**
	 * Creates a new instance of the {@link WebGLContextAttributes}.
	 * 
	 * @return the created instance.
	 */
	public final static WebGLContextAttributes create() {
		return JavaScriptObject.createObject().cast();
	}

	/**
	 * Returns weather alpha is turned on.
	 * 
	 * @return the state of the alpha flag
	 */
	public final native Boolean getAlpha() /*-{
		if(typeof(this.alpha) == 'undefined') {
			return null;
		}
		return this.alpha;
	}-*/;

	/**
	 * Sets a new value for the alpha flag.
	 * 
	 * @param alpha
	 *            the new state of the alpha flag
	 */
	public final native void setAlpha(Boolean alpha) /*-{
		if(alpha == null) {
			delete alpha;
		} else {
			this.alpha = alpha;
		}
	}-*/;

	/**
	 * Returns weather depth buffer is turned on for the rendering buffer.
	 * 
	 * @return the state of the depth flag
	 */
	public final native Boolean getDepth() /*-{
		if(typeof(this.depth) == 'undefined') {
			return null;
		}
		return this.depth;
	}-*/;

	/**
	 * Sets a new value for the depth flag.
	 * 
	 * @param depth
	 *            the new state of the depth flag
	 */
	public final native void setDepth(Boolean depth) /*-{
		if(depth == null) {
			delete depth;
		} else {
			this.depth = depth;
		}
	}-*/;

	/**
	 * Returns weather stencil buffer is turned on for the rendering buffer.
	 * 
	 * @return the state of the stencil flag
	 */
	public final native Boolean getStencil() /*-{
		if(typeof(this.stencil) == 'undefined') {
			return null;
		}
		return this.stencil;
	}-*/;

	/**
	 * Sets a new value for the stencil flag.
	 * 
	 * @param stencil
	 *            the new state of the stencil flag
	 */
	public final native void setStencil(Boolean stencil) /*-{
		if(stencil == null) {
			delete stencil;
		} else {
			this.stencil = stencil;
		}
	}-*/;

	/**
	 * Returns weather antialiasing is turned on for the rendering context.
	 * 
	 * @return the state of the antialias flag
	 */
	public final native Boolean getAntialias() /*-{
		if(typeof(this.antialias) == 'undefined') {
			return null;
		}
		return this.antialias;
	}-*/;

	/**
	 * Sets a new value for the antialias flag.
	 * 
	 * @param antialias
	 *            the new state of the antialias flag
	 */
	public final native void setAntialias(Boolean antialias) /*-{
		if(antialias == null) {
			delete antialias;
		} else {
			this.antialias = antialias;
		}
	}-*/;

	/**
	 * Returns weather premultiplied alpha is used.
	 * 
	 * @return the state of the premultiplied alpha flag
	 */
	public final native Boolean getPremultipliedAlpha() /*-{
		if(typeof(this.premultipliedAlpha) == 'undefined') {
			return null;
		}
		return this.premultipliedAlpha;
	}-*/;

	/**
	 * Sets a new value for the premultiplied alpha flag.
	 * 
	 * @param premultipliedAlpha
	 *            the new state of the premultiplied alpha flag
	 */
	public final native void setPremultipliedAlpha(Boolean premultipliedAlpha) /*-{
		if(premultipliedAlpha == null) {
			delete premultipliedAlpha;
		} else {
			this.premultipliedAlpha = premultipliedAlpha;
		}
	}-*/;
}