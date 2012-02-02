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

import com.google.gwt.core.client.GWT;

/**
 * A TypedArray is an {@link ArrayBufferView} that reads and writes value of one specific type
 * to/from an {@link ArrayBuffer}.
 * 
 * @param <T> the concrete subtype of the TypedArray itself. Used for methods using the type of the
 *          TypedArray as Parameter or return value.
 */
public abstract class TypedArray<T extends TypedArray<T>> extends ArrayBufferView {

  /**
   * Defines at compile time if the browser possibly supports {@link TypedArray}.
   */
  private static class TypedArrayCompileTimeSupport {

    /**
     * Compile time check if {@link TypedArray} is possibly supported.
     * 
     * @return true if might be supported, false otherwise.
     */
    boolean isSupported() {
      return false;
    }
  }

  /**
   * Implementation of the TypedArrayCompileTimeSupport for all browsers that possibly support
   * {@link TypedArray}s.
   */
  @SuppressWarnings("unused")
  private static class TypedArrayCompileTimeSupportTrue extends TypedArrayCompileTimeSupport {

    /**
     * @{inheritDoc
     */
    @Override
    boolean isSupported() {
      return true;
    }
  }

  /**
   * Instance of the {@link TypedArrayCompileTimeSupport} to check the availability of TypedArray at
   * compile time.
   */
  private static TypedArrayCompileTimeSupport compileTimeSupport;

  /**
   * Checks if the Browser supports the {@link TypedArray}.
   * 
   * @return true, if TypedArray is supported, false otherwise.
   */
  public static boolean isSupported() {
    if (compileTimeSupport == null) {
      compileTimeSupport = GWT.create(TypedArrayCompileTimeSupport.class);
    }
    if (!compileTimeSupport.isSupported()) {
      return false;
    }
    return isSupportedRuntime();
  };

  /**
   * Checks at runtime if the Browser supports the Typed Array API.
   * 
   * @return true, if TypedArray is supported, false otherwise.
   */
  private static native boolean isSupportedRuntime() /*-{
		// TypedArray isn't available as type to JS. So we use annother elemental type for the check.
		return !!(window.ArrayBuffer);
  }-*/;

  /**
   * protected standard constructor as specified by
   * {@link com.google.gwt.core.client.JavaScriptObject}.
   */
  protected TypedArray() {
    super();
  }

  /**
   * Returns the number of values of the array type contained in the array.
   * 
   * @return the number of values of the array type contained in the array.
   */
  public final native int getLength() /*-{
		return this.length;
  }-*/;

  /**
   * Set multiple values, of the given array to this array.
   * 
   * @param array the array to get the values from
   */
  public final native void set(T array)/*-{
		this.set(array);
  }-*/;

  /**
   * Set multiple values, of the given array to this array starting at the given offset.
   * 
   * @param array the array to get the values from
   * @param offset the offset to start setting the values
   */
  public final native void set(T array, int offset)/*-{
		this.set(array, offset);
  }-*/;

  /**
   * Returns a new {@link TypedArray} with the same underlying {@link ArrayBuffer}.
   * 
   * @param begin the beginning offset of the new {@link TypedArray} from the start of this
   *          {@link TypedArray}. If the value is negative, it's the offset from the end of this
   *          {@link TypedArray}.
   * @return the new Array
   */
  public final native T subarray(int begin)/*-{
		return this.subarray(begin);
  }-*/;

  /**
   * Returns a new {@link TypedArray} with the same underlying {@link ArrayBuffer}.
   * 
   * @param begin the beginning offset of the new {@link TypedArray} from the start of this
   *          {@link TypedArray}. If the value is negative, it's the offset from the end of this
   *          {@link TypedArray}.
   * @param end the end offset (exclusive). If the value is negative, it's the offset from the end
   *          of this {@link TypedArray}.
   * @return the new Array
   */
  public final native T subarray(int begin, int end)/*-{
		return this.subarray(begin, end);
  }-*/;

}
