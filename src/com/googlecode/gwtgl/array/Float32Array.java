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

import com.google.gwt.core.client.JsArrayNumber;

/**
 * {@link TypedArray} that contains 32 Bit float values.
 */
public class Float32Array extends TypedArray<Float32Array> {

  /**
   * Creates a new instance of the {@link Float32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link TypedArray}.
   * @return the created {@link Float32Array} or null if it isn't supported by the browser.
   */
  public static Float32Array create(ArrayBuffer buffer) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(buffer);
  }

  /**
   * Creates a new instance of the {@link Float32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Float32Array} is created using the byteOffset to specify the starting point (in
   * bytes) of the {@link Float32Array} relative to the beginning of the underlying
   * {@link ArrayBuffer}. The byte offset must match (multiple) the value length of this
   * {@link TypedArray}.
   * 
   * If the byteOffset is not valid for the given {@link ArrayBuffer}, an exception is thrown
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link TypedArray}.
   * @param byteOffset the offset relative to the beginning of the ArrayBuffer (multiple of the
   *          value length of this {@link TypedArray})
   * @return the newly created {@link Float32Array} or null if it isn't supported by the browser.
   */
  public static Float32Array create(ArrayBuffer buffer, int byteOffset) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(buffer, byteOffset);
  }

  /**
   * Creates a new instance of the {@link TypedArray} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Float32Array} is created using the byteOffset and length to specify the start and
   * end (in bytes) of the {@link Float32Array} relative to the beginning of the underlying
   * {@link ArrayBuffer}. The byte offset must match (multiple) the value length of this
   * {@link TypedArray}. The length is in values of the type of the {@link TypedArray}.
   * 
   * If the byteOffset or length is not valid for the given {@link ArrayBuffer}, an exception is
   * thrown.
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link TypedArray}.
   * @param byteOffset the offset relative to the beginning of the ArrayBuffer (multiple of the
   *          value length of this {@link TypedArray})
   * @param length the length of the {@link TypedArray} in vales.
   * @return the newly created {@link Float32Array} or null if it isn't supported by the browser.
   */
  public static Float32Array create(ArrayBuffer buffer, int byteOffset, int length) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(buffer, byteOffset, length);
  }

  /**
   * Creates a new instance of the {@link Float32Array} of the length of the given array in values.
   * The values contained in the given array are set to the newly created {@link Float32Array}.
   * 
   * @param array the array to get the values from
   * @return the created {@link Float32Array} or null if it isn't supported by the browser.
   */
  public static Float32Array create(float[] array) {
    return create(JsArrayUtil.wrapArray(array));
  }

  /**
   * Creates a new instance of the {@link Float32Array} of the same length (in values) as the given
   * {@link Float32Array} using a new ArrayBuffer. The new {@link TypedArray} is initialized with
   * the values of the given {@link TypedArray}. If necessary the values are converted to the value
   * type of the new {@link TypedArray}.
   * 
   * @param array the {@link TypedArray} to get the values from to initialize the new Array with
   * @return the created {@link Float32Array} or null if it isn't supported by the browser.
   */
  public static Float32Array create(TypedArray<?> array) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(array);
  }

  /**
   * Creates a new instance of the {@link Float32Array} of the given length in values. All values
   * are set to 0.
   * 
   * @param length the length in values of the type used by this {@link Float32Array}
   * @return the created {@link Float32Array}.
   */
  public static Float32Array create(int length) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(length);
  }

  /**
   * Creates a new instance of the {@link Float32Array} of the length of the given array in values.
   * The values contained in the given array are set to the newly created {@link Float32Array}.
   * 
   * @param array the array to get the values from
   * @return the created {@link Float32Array} or null if it isn't supported by the browser.
   */
  public static Float32Array create(JsArrayNumber array) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(array);
  }

  /**
   * Creates a new instance of the {@link Float32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link Float32Array}.
   * @return the created {@link Float32Array}.
   */
  private static native Float32Array createImpl(ArrayBuffer buffer) /*-{
		return new Float32Array(buffer);
  }-*/;

  /**
   * Creates a new instance of the {@link TypedArray} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Float32Array} is created using the byteOffset to specify the starting point (in
   * bytes) of the {@link Float32Array} relative to the beginning of the underlying
   * {@link ArrayBuffer}. The byte offset must match (multiple) the value length of this
   * {@link TypedArray}.
   * 
   * If the byteOffet is not valid for the given {@link ArrayBuffer}, an exception is thrown
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link Float32Array}.
   * @param byteOffset the offset relative to the beginning of the ArrayBuffer (multiple of the
   *          value length of this {@link TypedArray})
   * @return the newly created {@link Float32Array}.
   */
  private static native Float32Array createImpl(ArrayBuffer buffer, int byteOffset) /*-{
		return new Float32Array(buffer, byteOffset);
  }-*/;

  /**
   * Creates a new instance of the {@link Float32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Float32Array} is created using the byteOffset and length to specify the start and
   * end (in bytes) of the {@link Float32Array} relative to the beginning of the underlying
   * {@link ArrayBuffer}. The byte offset must match (multiple) the value length of this
   * {@link TypedArray}. The length is in values of the type of the {@link TypedArray}
   * 
   * If the byteOffset or length is not valid for the given {@link ArrayBuffer}, an exception is
   * thrown
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link TypedArray}.
   * @param byteOffset the offset relative to the beginning of the ArrayBuffer (multiple of the
   *          value length of this {@link TypedArray})
   * @param length the length of the {@link Float32Array} in vales.
   * @return the newly created {@link Float32Array}.
   */
  private static native Float32Array createImpl(ArrayBuffer buffer, int byteOffset, int length) /*-{
		return new Float32Array(buffer, byteOffset, length);
  }-*/;

  /**
   * Creates a new instance of the {@link Float32Array} of the same length (in values) as the given
   * {@link Float32Array} using a new ArrayBuffer. The new {@link TypedArray} is initialized with
   * the values of the given {@link TypedArray}. If necessary the values are converted to the value
   * type of the new {@link TypedArray}.
   * 
   * @param array the {@link TypedArray} to get the values from to initialize the new Array with
   * @return the created {@link Float32Array} or null if it isn't supported by the browser.
   */
  private static native Float32Array createImpl(TypedArray<?> array) /*-{
		return new Float32Array(array);
  }-*/;

  /**
   * Creates a new instance of the {@link Float32Array} of the given length in values. All values
   * are set to 0.
   * 
   * @param length the length in values of the type used by this {@link Float32Array}
   * @return the created {@link Float32Array}.
   */
  private static native Float32Array createImpl(int length) /*-{
		return new Float32Array(length);
  }-*/;

  /**
   * Creates a new instance of the {@link Float32Array} of the length of the given array in values.
   * The values contained in the given array are set to the newly created {@link Float32Array}.
   * 
   * @param array the array to get the values from
   * @return the created {@link Float32Array}.
   */
  private static native Float32Array createImpl(JsArrayNumber array) /*-{
		return new Float32Array(array);
  }-*/;

  /**
   * protected standard constructor as specified by
   * {@link com.google.gwt.core.client.JavaScriptObject}.
   */
  protected Float32Array() {
    super();
  }

  /**
   * Reads the value at the given index. The index is based on the value length of the type used by
   * this {@link TypedArray}. Accessing an index that doesn't exist will cause an exception.
   * 
   * 
   * @param index the index relative to the beginning of the TypedArray.
   * @return the value at the given index
   */
  public final native float get(int index) /*-{
		return this[index];
  }-*/;

  /**
   * Writes multiple values to the TypedArray using the values of the given Array.
   * 
   * @param array an array containing the new values to set.
   */
  public final void set(float[] array) {
    set(JsArrayUtil.wrapArray(array));
  }

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Writes the values
   * beginning at the given offset.
   * 
   * @param array an array containing the new values to set.
   * @param offset the offset relative to the beginning of the TypedArray.
   */
  public final void set(float[] array, int offset) {
    set(JsArrayUtil.wrapArray(array), offset);
  };

  /**
   * Writes the given value at the given index. The index is based on the value length of the type
   * used by this {@link TypedArray}. Accessing an index that doesn't exist will cause an exception.
   * 
   * Values that are out of the range for the type used by this TypedAray are silently casted to be
   * in range.
   * 
   * @param index the index relative to the beginning of the TypedArray.
   * @param value the new value to set
   */
  public final native void set(int index, float value) /*-{
		this[index] = value;
  }-*/;

  /**
   * Writes multiple values to the TypedArray using the values of the given Array.
   * 
   * @param array an array containing the new values to set.
   */
  public final native void set(JsArrayNumber array) /*-{
		this.set(array);
  }-*/;;

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Writes the values
   * beginning at the given offset.
   * 
   * @param array an array containing the new values to set.
   * @param offset the offset relative to the beginning of the TypedArray.
   */
  public final native void set(JsArrayNumber array, int offset) /*-{
		this.set(array, offset);
  }-*/;

}
