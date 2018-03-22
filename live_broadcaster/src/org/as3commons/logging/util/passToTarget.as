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
package org.as3commons.logging.util {
	
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.setup.target.LogStatement;
	
	/**
	 * Logs a list of log statements to a log target.
	 * 
	 * @param statements Array of log statements (first=oldest, last=newest);
	 * @param factory <code>ILogTarget</code> to flush to. 
	 * @since 2.5
	 */
	public function passToTarget(statements:Array,logTarget:ILogTarget):void {
		if(logTarget) {
			const l: int = statements.length;
			for( var i:int = 0; i<l; ++i) {
				var statement:LogStatement = LogStatement(statements[i]);
				logTarget.log(
					statement.name, statement.shortName, statement.level,
					statement.timeStamp, statement.message, statement.parameters,
					statement.person, statement.context, statement.shortContext
				);
			}
		}
	}
}
