/*
 * Copyright 2009-2011 Sönke Sothmann, Steffen Schäfer and others
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.googlecode.gwtgl.array;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * The ArrayBuffer is a buffer for the data of {@link TypedArray}s. It's the raw untyped store for
 * the data represented by the {@link TypedArray}s using this ArrayBuffer.
 * 
 */
public class ArrayBuffer extends JavaScriptObject {

  /**
   * Constructs a new ArrayBuffer instance. The newly created ArrayBuffer has the given length in
   * bytes. The ArrayBuffer is initialized with 0 values.
   * 
   * @param length the byte length of the newly created ArrayBuffer
   * @return the created ArrayBuffer or null if it isn't supported by the browser
   */
  public static ArrayBuffer create(int length) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(length);
  }

  /**
   * Constructs a new ArrayBuffer instance. The newly created ArrayBuffer has the given length in
   * bytes. The ArrayBuffer is initialized with 0 values.
   * 
   * @param length the byte length of the newly created ArrayBuffer
   * @return the created ArrayBuffer
   */
  private static native ArrayBuffer createImpl(int length) /*-{
		return new ArrayBuffer(length);
  }-*/;

  /**
   * protected standard constructor as specified by
   * {@link com.google.gwt.core.client.JavaScriptObject}.
   */
  protected ArrayBuffer() {
    super();
  }

  /**
   * Returns the non changeable length of the ArrayBuffer in bytes.
   * 
   * @return the non changeable length of the ArrayBuffer in bytes.
   */
  public final native int getByteLength() /*-{
		return this.byteLength;
  }-*/;

}
