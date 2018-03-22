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
	import org.as3commons.logging.api.ILogTarget;

	/**
	 * <code>ChainsawTarget</code> sends events to Chainsaw, a tool from the log4j
	 * platform.
	 * 
	 * @author Martin Heidegger
	 * @see http://logging.apache.org/chainsaw
	 * @see org.as3commons.logging.setup.target.ChainsawGateway
	 * @since 2.7
	 */
	public final class ChainsawTarget implements ILogTarget {
		
		/** Default format used to format the log statement */
		public static const DEFAULT_FORMAT: String = "{message_dqt}";
		
		/** Contains the standard gateway used if no custom one is required. */
		public static const DEFAULT_GATEWAY: ChainsawGateway = new ChainsawGateway();
		
		/** Formatter used to render the log statements. */
		private var _formatter:LogMessageFormatter;
		
		/** Gateway used to send SOS targets. */
		private var _gateway:ChainsawGateway;
		
		/**
		 * Constructs a new <code>ChainsawTarget</code>
		 * 
		 * @param format Format to be used to format the statements.
		 * @param gateway Gateway to the SOS that runs. Will use the default gateway
		 *        in case no custom one is provided. 
		 */
		public function ChainsawTarget(format:String=null, gateway:ChainsawGateway=null) {
			this.format = format;
			_gateway = gateway||DEFAULT_GATEWAY;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:*,
							person:String, context:String, shortContext:String):void {
			if(person) {
				name += "@" + person;
			}
			_gateway.log(name, timeStamp, level,
				_formatter.format(name, shortName, level, timeStamp, message,
									parameters, person, context, shortContext)
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
