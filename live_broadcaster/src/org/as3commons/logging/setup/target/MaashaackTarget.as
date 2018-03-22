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
	
	import system.logging.LoggerStrings;
	import system.logging.Log;
	import system.logging.Logger;
	import system.logging.LoggerLevel;
	import org.as3commons.logging.util.LogMessageFormatter;
	import org.as3commons.logging.api.ILogTarget;
	
	/**
	 * <code>MaashaackTarget</code> sents messages to the Maashaack logging system.
	 * 
	 * <listing>
	 * import org.as3commons.logging.api.LOGGER_FACTORY;
	 * import org.as3commons.logging.api.getLogger;
	 * import org.as3commons.logging.setup.SimpleTargetSetup;
	 * import org.as3commons.logging.setup.target.MaashaaackTarget;
	 * 
	 * LOGGER_FACTORY.setup = new SimpleTargetSetup(new MaashaackTarget);
	 * 
	 * getLogger("myclass").info("hi"); // sends "hi" to the maashaack logging sytem.
	 * </listing>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @since 2.7
	 * @see http://code.google.com/p/maashaack/
	 * @see org.as3commons.logging.integration.MaashaackIntegration
	 */
	public final class MaashaackTarget implements ILogTarget {
		
		public static const DEFAULT_FORMAT: String = "{logTime} {message} {atPerson}";
		private static const ILL_CHR: Array = LoggerStrings.ILLEGALCHARACTERS.split("");
		private static const ILL_CHR_LEN: uint = LoggerStrings.ILLEGALCHARACTERS.length; 
		
		private var _formatter: LogMessageFormatter;
		
		public function MaashaackTarget(format:String=null) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format( format:String ): void {
			_formatter = new LogMessageFormatter( format||DEFAULT_FORMAT );
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:*,
							person:String, context:String, shortContext:String): void {
			var cleanName: String = _cleanNames[name];
			if(!cleanName) {
				for( var i: int = 0; i<ILL_CHR_LEN; ++i ) {
					var c: String = ILL_CHR[i];
					if( name.indexOf(c) != -1 ) {
						name = name.split(c).join("");
					}
				}
				_cleanNames[name] = cleanName = name;
			}
			var logger: Logger = _loggers[cleanName] ||= Log.getLogger(cleanName);
			_entry.channel = cleanName;
			_entry.level = _levelMap[level] || LoggerLevel.DEBUG;
			_entry.message = _formatter.format(name, shortName, level, timeStamp,
								message, parameters, person, context, shortContext);
			logger.emit( _entry );
		}
	}
}

import system.logging.LoggerLevel;
import system.logging.LoggerEntry;
import org.as3commons.logging.level.FATAL;
import org.as3commons.logging.level.ERROR;
import org.as3commons.logging.level.WARN;
import org.as3commons.logging.level.INFO;
import org.as3commons.logging.level.DEBUG;

const _entry: LoggerEntry = new LoggerEntry();
const _loggers: Object = {};
const _cleanNames: Object = {};
const _levelMap: Object = {};
{
	_levelMap[DEBUG] = LoggerLevel.DEBUG;
	_levelMap[INFO] = LoggerLevel.INFO;
	_levelMap[WARN] = LoggerLevel.WARN;
	_levelMap[ERROR] = LoggerLevel.ERROR;
	_levelMap[FATAL] = LoggerLevel.FATAL;
}