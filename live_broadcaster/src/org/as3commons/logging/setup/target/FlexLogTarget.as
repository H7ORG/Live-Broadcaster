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

	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	/**
	 * Target that sends the targets to the <code>mx.logging</code> log system from Flex.
	 * 
	 * @author Christophe Herreman
	 * @author Martin Heidegger
	 * @since 2.0
	 */
	public final class FlexLogTarget extends AbstractClassicTarget {
		
		/** All the Flex loggers requested for that logger */
		private const _loggers:Object = {};
		private const _cleanNames:Object = {};
		
		public function FlexLogTarget() {}
		
		/**
		 * @inheritDoc
		 */
		override protected function doLog(name:String, shortName:String, level:int,
										  timeStamp:Number, message:String, parameter:Array,
										  person:String, context:String, shortContext:String):void {
			// Bug http://code.google.com/p/as3-commons/issues/detail?id=114
			if( person ) {
				name += "-"+person;
			}
			var cleanName: String = _cleanNames[name];
			if( !cleanName ) {
				cleanName = name.replace(/[\[\]\~\$\^\&\\(\)\{\}\+\?\/=`!@#%,:;'"<>\s]/g, '-');
				_cleanNames[name] = cleanName;
			}
			if( parameter ) {
				parameter.unshift(message);
			} else {
				parameter = [message];
			}
			var target:ILogger = _loggers[cleanName]||=Log.getLogger(cleanName);
			switch(level) {
				case DEBUG:
					target.debug.apply(null, parameter);
					break;
				case INFO:
					target.info.apply(null, parameter);
					break;
				case WARN:
					target.warn.apply(null, parameter);
					break;
				case ERROR:
					target.error.apply(null, parameter);
					break;
				case FATAL:
					target.fatal.apply(null, parameter);
					break;
			}
		}
	}
}
