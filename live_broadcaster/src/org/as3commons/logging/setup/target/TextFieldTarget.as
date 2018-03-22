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
	
	import org.as3commons.logging.util.LogMessageFormatter;
	
	import flash.text.TextField;
	
	/**
	 * <code>TextFieldTarget</code> is a simple target that formats log statements
	 * and renders them to a <code>TextField</code>.
	 * 
	 * 
	 * @author Martin Heidegger
	 * @since 2.0
	 */
	public final class TextFieldTarget extends TextField implements IFormattingLogTarget {
		
		/** Default format used to stringify the log statements. */
		public static const DEFAULT_FORMAT: String = "{time} {logLevel} - {shortName}{atPerson} - {message}\n";
		
		/** Formatter that formats the log statements. */
		private var _formatter:LogMessageFormatter;
		
		/** Textfield that shows the content */
		private var _textField:TextField;
		
		/**
		 * Creates a new TextFieldTarget.
		 * 
		 * @param format Default format to for the logging, if null, it will use
		 *        the <code>DEFAULT_FORMAT</code>.
		 * @param textField <code>TextField</code> to be used for logging, if null
		 *        it will log to itself.
		 */
		public function TextFieldTarget(format:String=null, textField:TextField=null) {
			this.format = format;
			_textField = textField || this;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int, timeStamp:Number,
							message:String, parameter:*, person:String, context:String,
							shortContext:String):void {
			_textField.appendText(
				_formatter.format(name, shortName, level, timeStamp, message,
									parameter, person, context, shortContext)
			);
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format(format:String):void {
			_formatter = new LogMessageFormatter(format||DEFAULT_FORMAT);
		}
	}
}