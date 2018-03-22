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
	 * Defines a target that needs to store data before logging it.
	 * 
	 * <p>To preserve the variables passed in to the log statement asynchronous
	 * loggers need to clone instances to store the log statements. They use
	 * for this the <code>clone</code> method.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see org.as3commons.logging.util#clone
	 */
	public interface IAsyncLogTarget extends ILogTarget {
		
		/**
		 * Asynchronous targets need to introspect variables to store them,
		 * for that the introspection depth defines how deep the variables should
		 * be serialized. (default=uint.MAX_VALUE)
		 */
		function set introspectDepth(depth:uint): void;
	}
}
