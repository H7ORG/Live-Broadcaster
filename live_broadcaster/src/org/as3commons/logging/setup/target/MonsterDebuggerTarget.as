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
	
	import nl.demonsters.debugger.MonsterDebugger;
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.ERROR;
	import org.as3commons.logging.level.FATAL;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.setup.target.IColorableLogTarget;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	/**
	 * <code>MonsterDebuggerTarget</code> logs directly to the monster debugger.
	 * 
	 * <p>The Monster Debugger is an alternative way to display your logging statements.
	 * This target is pretty straightforward about sending it to the Monster Debugger.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.0
	 * @version 1.1
	 * @see http://demonsterdebugger.com
	 */
	public final class MonsterDebuggerTarget implements IColorableLogTarget {
		/** Default output format used to stringify the log statements. */
		public static const DEFAULT_FORMAT: String = "{time} {shortName}{atPerson} - {message}";
		
		/** Default colors used to color the output statements. */
		public static const DEFAULT_COLORS: Object = {};
		{
			DEFAULT_COLORS[DEBUG] = MonsterDebugger.COLOR_NORMAL;
			DEFAULT_COLORS[FATAL] = MonsterDebugger.COLOR_ERROR;
			DEFAULT_COLORS[ERROR] = MonsterDebugger.COLOR_ERROR;
			DEFAULT_COLORS[INFO] = MonsterDebugger.COLOR_NORMAL;
			DEFAULT_COLORS[WARN] = MonsterDebugger.COLOR_WARNING;
		}
		
		/** Colors used to display the messages. */
		private var _colors:Object;
		
		/** Formatter that renders the log statements. */
		private var _formatter:LogMessageFormatter;
		
		/**
		 * Constructs a new <code>MonsterDebuggerTarget</code>
		 * 
		 * @param format Default format used to render log statements.
		 * @param colors Default colors used to color log statements.
		 */
		public function MonsterDebuggerTarget(format:String=null,colors:Object=null) {
			this.format = format||DEFAULT_FORMAT;
			this.colors = colors||DEFAULT_COLORS;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set colors(colors:Object):void {
			_colors = colors||DEFAULT_COLORS;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format(format:String):void {
			_formatter = new LogMessageFormatter(format||DEFAULT_FORMAT);
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameter:*,
							person:String, context:String, shortContext:String): void {
			
			MonsterDebugger.trace( name, _formatter.format(name, shortName, level, timeStamp,
									   message, parameter, person, context, shortContext), _colors[ level ]);
		}
	}
}