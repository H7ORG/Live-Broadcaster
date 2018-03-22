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
	 * A <code>IFormattingLogTarget</code> is a <code>ILogTarget</code> that formats
	 * the input to a string.
	 * 
	 * @author Martin Heidegger
	 * @since 2
	 * @see org.as3commons.logging.util.LogMessageFormatter
	 */
	public interface IFormattingLogTarget extends ILogTarget {
		
		/**
		 * Defines the format used by the target to transform the log statement
		 * to a string.
		 * 
		 * <p>The format passed in can use any of the the following definitions:</p>
		 * 
		 * <table>
		 *   <tr><th>Field</th>
		 *       <th>Description</th></tr>
		 * 
		 *   <tr><td>{date}</td>
		 *       <td>The date in the format <code>YYYY/MM/DD</code></td></tr>
		 * 
		 *   <tr><td>{dateUTC}</td>
		 *       <td>The UTC date in the format <code>YYYY/MM/DD</code></td></tr>
		 * 
		 *   <tr><td>{gmt}</td>
		 *       <td>The time offset of the statement to the Greenwich mean time in the format <code>GMT+9999</code></td></tr>
		 
		 *   <tr><td>{logLevel}</td>
		 *       <td>The level of the log statement (example: <code>DEBUG</code> )</td></tr>
		 * 
		 *   <tr><td>{logTime}</td>
		 *       <td>The UTC time in the format <code>HH:MM:SS.0MS</code></td></tr>
		 * 
		 *   <tr><td>{message}</td>
		 *       <td>The message of the logger</td></tr>
		 * 
		 *   <tr><td>{message_dqt}</td>
		 *       <td>The message of the logger, double quote escaped.</td></tr>
		 * 
		 *   <tr><td>{name}</td>
		 *       <td>The name of the logger</td></tr>
		 * 
		 *   <tr><td>{time}</td>
		 *       <td>The time in the format <code>H:M:S.MS</code></td></tr>
		 *   
		 *   <tr><td>{timeUTC}</td>
		 *       <td>The UTC time in the format <code>H:M:S.MS</code></td></tr>
		 *   
		 *   <tr><td>{shortName}</td>
		 *       <td>The short name of the logger</td></tr>
		 *   
		 *   <tr><td>{shortSWF}</td>
		 *       <td>The SWF file name</td></tr>
		 *   
		 *   <tr><td>{swf}</td>
		 *       <td>The full SWF path</td></tr>
		 *   
		 *   <tr><td>{person}</td>
		 *       <td>The Person that wrote this statement</td></tr>
		 *   
		 *   <tr><td>{atPerson}</td>
		 *       <td>The Person that wrote this statement with the 'at' prefix</td></tr>
		 * </table>
		 * 
		 * @example <listing>
		 *    formattingLogTarget.format = "{shortName} - {logLevel) - {message}";
		 *    logger = getLogger(mypackage.MyClass);
		 *    logger.debug('Hello World');
		 *    // example output: 'MyClass - DEBUG - Hello World';
		 * </listing>
		 * 
		 * @param format Format which the target should use to stringify the log
		 *        statements.
		 * @see org.as3commons.logging.util.LogMessageFormatter
		 * @see org.as3commons.logging.util.SWFInfo#init()
		 * @see org.as3commons.logging.util#SWF_URL
		 * @see org.as3commons.logging.util#SWF_SHORT_URL
		 */
		function set format(format:String):void;
	}
}
