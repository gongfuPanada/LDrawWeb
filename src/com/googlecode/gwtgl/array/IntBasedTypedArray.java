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

import com.google.gwt.core.client.JsArrayInteger;

/**
 * Abstract parent class for all {@link TypedArray}s which use int to get/set the inner values. Do
 * not rely on this class as it's not part of the spec and only introduced in GwtGL to simplify the
 * implementation of the Int*Arrays.
 * 
 * @param <T> the type of the {@link TypedArray} itself. Used for methods that use parameters that
 *          must have the same type than the TypedArray itself.
 */
public abstract class IntBasedTypedArray<T extends IntBasedTypedArray<T>> extends TypedArray<T> {

  /**
   * protected standard constructor as specified by
   * {@link com.google.gwt.core.client.JavaScriptObject}.
   */
  protected IntBasedTypedArray() {
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
  public final native int get(int index) /*-{
		return this[index];
  }-*/;

  /**
   * Reads the value at the given index. The index is based on the value length of the type used by
   * this {@link TypedArray}. Accessing an index that doesn't exist will cause an exception.
   * 
   * 
   * @param index the index relative to the beginning of the TypedArray.
   * @return the value at the given index
   */
  public final native byte getByte(int index) /*-{
		return this[index];
  }-*/;

  /**
   * Reads the value at the given index. The index is based on the value length of the type used by
   * this {@link TypedArray}. Accessing an index that doesn't exist will cause an exception.
   * 
   * 
   * @param index the index relative to the beginning of the TypedArray.
   * @return the value at the given index
   */
  public final long getLong(int index) {
    return Long.parseLong(getLongImpl(index));
  }

  /**
   * Reads the value at the given index. The index is based on the value length of the type used by
   * this {@link TypedArray}. Accessing an index that doesn't exist will cause an exception.
   * 
   * 
   * @param index the index relative to the beginning of the TypedArray.
   * @return the value at the given index
   */
  public final native short getShort(int index) /*-{
		return this[index];
  }-*/;;

  /**
   * Writes multiple values to the TypedArray using the values of the given Array.
   * 
   * @param array an array containing the new values to set.
   */
  public final void set(byte[] array) {
    set(JsArrayUtil.wrapArray(array));
  }

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Writes the values
   * beginning at the given offset.
   * 
   * @param array an array containing the new values to set.
   * @param offset the offset relative to the beginning of the TypedArray.
   */
  public final void set(byte[] array, int offset) {
    set(JsArrayUtil.wrapArray(array), offset);
  }

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
  public final native void set(int index, byte value) /*-{
		this[index] = value;
  }-*/;

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
  public final native void set(int index, int value) /*-{
		this[index] = value;
  }-*/;

  /**
   * Writes the given value at the given index. The index is based on the value length of the type
   * used by this {@link TypedArray}. Accessing an index that doesn't exist will cause an exception.
   * 
   * Values that are out of the range for the type used by this TypedAray are silently casted to be
   * in range.
   * 
   * Pay attention: Avoid using long values in GWT if possible (
   * {@link "http://code.google.com/intl/de-DE/webtoolkit/doc/latest/DevGuideCodingBasicsCompatibility.html#language"}
   * ). This method has poor performance in production mode compared with the int version (
   * {@link IntBasedTypedArray#set(int,int)}). Please note that in production mode int, short and
   * byte are handled as 64Bit floating point values, so you can use them for values >2^31-1. Keep
   * in mind that not every long value can be represented exactly by 64Bit floating values. Be aware
   * that this won't work correctly in dev mode and no literals above that limit are supported in
   * Java.
   * 
   * @param index the index relative to the beginning of the TypedArray.
   * @param value the new value to set
   */
  public final void set(int index, long value) {
    setImpl(index, Long.toString(value));
  }

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
  public final native void set(int index, short value) /*-{
		this[index] = value;
  }-*/;

  /**
   * Writes multiple values to the TypedArray using the values of the given Array.
   * 
   * @param array an array containing the new values to set.
   */
  public final void set(int[] array) {
    set(JsArrayUtil.wrapArray(array));
  };

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Writes the values
   * beginning at the given offset.
   * 
   * @param array an array containing the new values to set.
   * @param offset the offset relative to the beginning of the TypedArray.
   */
  public final void set(int[] array, int offset) {
    set(JsArrayUtil.wrapArray(array), offset);
  }

  /**
   * Writes multiple values to the TypedArray using the values of the given Array.
   * 
   * @param array an array containing the new values to set.
   */
  public final native void set(JsArrayInteger array) /*-{
		this.set(array);
  }-*/;;

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Writes the values
   * beginning at the given offset.
   * 
   * @param array an array containing the new values to set.
   * @param offset the offset relative to the beginning of the TypedArray.
   */
  public final native void set(JsArrayInteger array, int offset) /*-{
		this.set(array, offset);
  }-*/;

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Pay attention:
   * Avoid using long values in GWT if possible (
   * {@link "http://code.google.com/intl/de-DE/webtoolkit/doc/latest/DevGuideCodingBasicsCompatibility.html#language"}
   * ). This method has poor performance in production mode compared with the int[] version (
   * {@link IntBasedTypedArray#set(int[])}). Please note that in production mode int, short and byte
   * are handled as 64Bit floating point values, so you can use them for values >2^31-1. Keep in
   * mind that not every long value can be represented exactly by 64Bit floating values. Be aware
   * that this won't work correctly in dev mode and no literals above that limit are supported in
   * Java.
   * 
   * @param array an array containing the new values to set.
   */
  public final void set(long[] array) {
    set(JsArrayUtil.wrapArray(array));
  };

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Writes the values
   * beginning at the given offset. Pay attention: Avoid using long values in GWT if possible (
   * {@link "http://code.google.com/intl/de-DE/webtoolkit/doc/latest/DevGuideCodingBasicsCompatibility.html#language"}
   * ). This method has poor performance in production mode compared with the int[] version (
   * {@link IntBasedTypedArray#set(int[], int)}). Please note that in production mode int, short and
   * byte are handled as 64Bit floating point values, so you can use them for values >2^31-1. Keep
   * in mind that not every long value can be represented exactly by 64Bit floating values. Be aware
   * that this won't work correctly in dev mode and no literals above that limit are supported in
   * Java.
   * 
   * @param array an array containing the new values to set.
   * @param offset the offset relative to the beginning of the TypedArray.
   */
  public final void set(long[] array, int offset) {
    set(JsArrayUtil.wrapArray(array), offset);
  }

  /**
   * Writes multiple values to the TypedArray using the values of the given Array.
   * 
   * @param array an array containing the new values to set.
   */
  public final void set(short[] array) {
    set(JsArrayUtil.wrapArray(array));
  };

  /**
   * Writes multiple values to the TypedArray using the values of the given Array. Writes the values
   * beginning at the given offset.
   * 
   * @param array an array containing the new values to set.
   * @param offset the offset relative to the beginning of the TypedArray.
   */
  public final void set(short[] array, int offset) {
    set(JsArrayUtil.wrapArray(array), offset);
  }

  /**
   * Implementation for getLong that returns the value as String to be later parsed as long.
   * 
   * @param index the index relative to the beginning of the TypedArray.
   * @return the value at the given index
   */
  private native String getLongImpl(int index) /*-{
		return "" + this[index];
  }-*/;;

  /**
   * Implementation for setting long values using Strings as longs are emulated in GWT and can't be
   * directly used in JSNI.
   * 
   * @param index the index to set the value at
   * @param value the value to set
   */
  private native void setImpl(int index, String value) /*-{
		this[index] = parseInt(value);
  }-*/;
}