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
package org.as3commons.logging.api {
	
	/**
	 * <code>LOGGER_FACTORY</code> contains the default <code>LoggerFactory</code>
	 * used by <code>getLogger</code> and its siblings.
	 * 
	 * <p>All <code>Logger</code> instances returned by <code>getLogger()</code>,
	 * are generated and held by this instance.</p>
	 * 
	 * <listing>
	 *    LOGGER_FACTORY.setup = null; // Sets all output to null.
	 *    LOGGER_FACTORY.setup = new SimpleTargetSetup( new SOSTarget );
	 *    // Logs all targets to the SOS Target
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.0
	 * @see org.as3commons.logging.api#getLogger()
	 * @see org.as3commons.logging.api#getNamedLogger()
	 * @see org.as3commons.logging.api#getClassLogger()
	 */
	public const LOGGER_FACTORY: LoggerFactory = new LoggerFactory();
}
