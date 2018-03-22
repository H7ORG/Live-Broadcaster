/*
 * Copyright (c) 2008-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.logging.simple {
	
	/**
	 * If set to true <code>true</code> it will show the line numbers for the 
	 * log statements.
	 * 
	 * <p>This switch is available for the case one has too many logging calls
	 * and the flash player gets unbearable slow. In that particular case 
	 * <code>USE_LINE_NUMBERS</code> will reduce at least the amount of loggers
	 * instantiated. (not one per line but one per method. This setting is
	 * only effective if the swf is compiled for debugging and it runs in a debug
	 * player.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.6
	 */
	public var USE_LINE_NUMBERS: Boolean = true;
}
