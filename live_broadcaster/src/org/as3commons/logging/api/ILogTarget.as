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
	 * A <code>ILogTarget</code> implementation is to log statements to a target.
	 * 
	 * @author Martin Heidegger
	 * @version 2
	 * @since 2
	 */
	public interface ILogTarget {
		
		/**
		 * Renders a log statement.
		 * 
		 * <p>In version 3 the person information was added and the time stamp
		 * was modified to represent the local time rather than the time in gmt.
		 * Add <code>START_TIME</code> to get the time in ms since 1970.</p>
		 * 
		 * <p>In version 2.5 the person information was added and the time stamp
		 * was modified to represent the local time rather than the time in gmt.
		 * Add <code>START_TIME</code> to get the time in ms since 1970.</p>
		 * 
		 * @param name Name of the logger that triggered the log statement.
		 * @param shortName Shortened form of the name.
		 * @param level Level of the log statement that got triggered.
		 * @param timeStamp getTimer() Timestame of when the log statement was triggered.
		 * @param message Message of the log statement. (can be null)
		 * @param parameters Parameters for the log statement. (can be null)
		 * @param person Information about the person that filed this log statement. (can be null)
		 * @param context Name of the context in which this logger was called. (can be null)
		 * @param context Shortened form of the context. (can be null)
		 * @version 3
		 */
		function log(name:String, shortName:String, level:int, timeStamp:Number,
					message:String, parameters:*, person:String, context:String,
					shortContext:String):void;
	}
}
