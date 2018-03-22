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
package org.as3commons.logging.setup.target {
	
	import org.as3commons.logging.api.ILogTarget;
	
	/**
	 * This interface describes targets that allow coloring of log statements.
	 * 
	 * @author Martin Heidegger
	 * @version 1.0
	 * @since 2.5
	 */
	public interface IColorableLogTarget extends ILogTarget {
		
		/**
		 * The colors used to to send the log statement.
		 * 
		 * <p>This target supports custom colors for log statements. These
		 * can be changed dynamically if you pass here a Dictionary with Colors (numbers)
		 * used for all levels:</p>
		 * 
		 * <p>The default colors used in case <code>null</code> got passed-in
		 * should be documented in the implementations.</p>
		 * 
		 * @example <listing>
		 *     import org.as3commons.logging.level.*;
		 *     
		 *     target.colors = {
		 *       DEBUG: 0x00FF00,
		 *       INFO: 0x00FFFF,
		 *       WARN: 0xFF0000,
		 *       ERROR: 0x0000FF,
		 *       FATAL: 0xFFFF00
		 *     };
		 * </listing>
		 */
		function set colors( colors:Object ):void;
	}
}
