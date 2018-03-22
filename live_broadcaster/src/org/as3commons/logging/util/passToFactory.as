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
	
	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.api.Logger;
	import org.as3commons.logging.api.LoggerFactory;
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.setup.target.LogStatement;
	
	/**
	 * Logs a list of log statements to a factory.
	 * 
	 * @param statements Array of log statements (first=oldest, last=newest);
	 * @param factory <code>LoggerFactory</code> to flush to.
	 *                <code>LOGGER_FACTORY</code> will be used if null is passed-in. 
	 * @since 2.5
	 */
	public function passToFactory(statements:Array,factory:LoggerFactory=null):void {
		factory||=LOGGER_FACTORY;
		const l: int = statements.length;
		for( var i:int = 0; i<l; ++i) {
			var statement:LogStatement = LogStatement(statements[i]);
			var logger:Logger = factory.getNamedLogger(statement.name,statement.person) as Logger;
			
			var logTarget: ILogTarget;
			if(statement.level == DEBUG) {
				logTarget = logger.debugTarget;
			} else if(statement.level == INFO) {
				logTarget = logger.infoTarget;
			} else if(statement.level == WARN) {
				logTarget = logger.warnTarget;
			} else if(statement.level == ERROR) {
				logTarget = logger.errorTarget;
			} else if(statement.level == FATAL) {
				logTarget = logger.fatalTarget;
			}
			
			if(logTarget) {
				logTarget.log(
					statement.name, statement.shortName, statement.level,
					statement.timeStamp, statement.message, statement.parameters,
					statement.person, statement.context, statement.shortContext
				);
			}
		}
	}
}
