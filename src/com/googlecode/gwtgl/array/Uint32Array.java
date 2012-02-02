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
 * {@link TypedArray} that contains 32 Bit unsigned integer values.
 * 
 */
public class Uint32Array extends IntBasedTypedArray<Uint32Array> {

  /**
   * Creates a new instance of the {@link Uint32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link TypedArray}.
   * @return the created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  public static Uint32Array create(ArrayBuffer buffer) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(buffer);
  }

  /**
   * Creates a new instance of the {@link Uint32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Uint32Array} is created using the byteOffset to specify the starting point (in
   * bytes) of the {@link Uint32Array} relative to the beginning of the underlying
   * {@link ArrayBuffer}. The byte offset must match (multiple) the value length of this
   * {@link TypedArray}.
   * 
   * If the byteOffset is not valid for the given {@link ArrayBuffer}, an exception is thrown
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link TypedArray}.
   * @param byteOffset the offset relative to the beginning of the ArrayBuffer (multiple of the
   *          value length of this {@link TypedArray})
   * @return the newly created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  public static Uint32Array create(ArrayBuffer buffer, int byteOffset) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(buffer, byteOffset);
  }

  /**
   * Creates a new instance of the {@link TypedArray} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Uint32Array} is created using the byteOffset and length to specify the start and end
   * (in bytes) of the {@link Uint32Array} relative to the beginning of the underlying
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
   * @return the newly created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  public static Uint32Array create(ArrayBuffer buffer, int byteOffset, int length) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(buffer, byteOffset, length);
  }

  /**
   * Creates a new instance of the {@link Uint32Array} of the given length in values. All values are
   * set to 0.
   * 
   * @param length the length in values of the type used by this {@link Uint32Array}
   * @return the created {@link Uint32Array}.
   */
  public static Uint32Array create(int length) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(length);
  }

  /**
   * Creates a new instance of the {@link Uint32Array} of the length of the given array in values.
   * The values contained in the given array are set to the newly created {@link Uint32Array}.
   * 
   * @param array the array to get the values from
   * @return the created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  public static Uint32Array create(int[] array) {
    return create(JsArrayUtil.wrapArray(array));
  }

  /**
   * Creates a new instance of the {@link Uint32Array} of the length of the given array in values.
   * The values contained in the given array are set to the newly created {@link Uint32Array}.
   * 
   * Pay attention: Avoid using long values in GWT if possible (
   * {@link "http://code.google.com/intl/de-DE/webtoolkit/doc/latest/DevGuideCodingBasicsCompatibility.html#language"}
   * ). This method has poor performance compared with the int[] version (
   * {@link Uint32Array#create(int[])}). Please note that in production mode int, short and byte are
   * handled as 64Bit floating point values, so you can use them for values >2^31-1. Keep in mind
   * that not every long value can be represented exactly by 64Bit floating values. Be aware that
   * this won't work correctly in dev mode and no literals above that limit are supported in Java.
   * 
   * @param array the array to get the values from
   * @return the created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  public static Uint32Array create(long[] array) {
    return create(JsArrayUtil.wrapArray(array));
  }

  /**
   * Creates a new instance of the {@link Uint32Array} of the length of the given array in values.
   * The values contained in the given array are set to the newly created {@link Uint32Array}.
   * 
   * @param array the array to get the values from
   * @return the created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  public static Uint32Array create(JsArrayInteger array) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(array);
  }

  /**
   * Creates a new instance of the {@link Uint32Array} of the same length (in values) as the given
   * {@link Uint32Array} using a new ArrayBuffer. The new {@link TypedArray} is initialized with the
   * values of the given {@link TypedArray}. If necessary the values are converted to the value type
   * of the new {@link TypedArray}.
   * 
   * @param array the {@link TypedArray} to get the values from to initialize the new Array with
   * @return the created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  public static Uint32Array create(TypedArray<?> array) {
    if (!TypedArray.isSupported()) {
      return null;
    }
    return createImpl(array);
  }

  /**
   * Creates a new instance of the {@link Uint32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link Uint32Array}.
   * @return the created {@link Uint32Array}.
   */
  private static native Uint32Array createImpl(ArrayBuffer buffer) /*-{
		return new Uint32Array(buffer);
  }-*/;

  /**
   * Creates a new instance of the {@link TypedArray} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Uint32Array} is created using the byteOffset to specify the starting point (in
   * bytes) of the {@link Uint32Array} relative to the beginning of the underlying
   * {@link ArrayBuffer}. The byte offset must match (multiple) the value length of this
   * {@link TypedArray}.
   * 
   * If the byteOffet is not valid for the given {@link ArrayBuffer}, an exception is thrown
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link Uint32Array}.
   * @param byteOffset the offset relative to the beginning of the ArrayBuffer (multiple of the
   *          value length of this {@link TypedArray})
   * @return the newly created {@link Uint32Array}.
   */
  private static native Uint32Array createImpl(ArrayBuffer buffer, int byteOffset) /*-{
		return new Uint32Array(buffer, byteOffset);
  }-*/;

  /**
   * Creates a new instance of the {@link Uint32Array} using the given {@link ArrayBuffer} to
   * read/write values from/to.
   * 
   * The {@link Uint32Array} is created using the byteOffset and length to specify the start and end
   * (in bytes) of the {@link Uint32Array} relative to the beginning of the underlying
   * {@link ArrayBuffer}. The byte offset must match (multiple) the value length of this
   * {@link TypedArray}. The length is in values of the type of the {@link TypedArray}
   * 
   * If the byteOffset or length is not valid for the given {@link ArrayBuffer}, an exception is
   * thrown
   * 
   * @param buffer the underlying {@link ArrayBuffer} of the newly created {@link TypedArray}.
   * @param byteOffset the offset relative to the beginning of the ArrayBuffer (multiple of the
   *          value length of this {@link TypedArray})
   * @param length the length of the {@link Uint32Array} in vales.
   * @return the newly created {@link Uint32Array}.
   */
  private static native Uint32Array createImpl(ArrayBuffer buffer, int byteOffset, int length) /*-{
		return new Uint32Array(buffer, byteOffset, length);
  }-*/;

  /**
   * Creates a new instance of the {@link Uint32Array} of the given length in values. All values are
   * set to 0.
   * 
   * @param length the length in values of the type used by this {@link Uint32Array}
   * @return the created {@link Uint32Array}.
   */
  private static native Uint32Array createImpl(int length) /*-{
		return new Uint32Array(length);
  }-*/;

  /**
   * Creates a new instance of the {@link Uint32Array} of the length of the given array in values.
   * The values contained in the given array are set to the newly created {@link Uint32Array}.
   * 
   * @param array the array to get the values from
   * @return the created {@link Uint32Array}.
   */
  private static native Uint32Array createImpl(JsArrayInteger array) /*-{
		return new Uint32Array(array);
  }-*/;

  /**
   * Creates a new instance of the {@link Uint32Array} of the same length (in values) as the given
   * {@link Uint32Array} using a new ArrayBuffer. The new {@link TypedArray} is initialized with the
   * values of the given {@link TypedArray}. If necessary the values are converted to the value type
   * of the new {@link TypedArray}.
   * 
   * @param array the {@link TypedArray} to get the values from to initialize the new Array with
   * @return the created {@link Uint32Array} or null if it isn't supported by the browser.
   */
  private static native Uint32Array createImpl(TypedArray<?> array) /*-{
		return new Uint32Array(array);
  }-*/;

  /**
   * protected standard constructor as specified by
   * {@link com.google.gwt.core.client.JavaScriptObject}.
   */
  protected Uint32Array() {
    super();
  }

}
