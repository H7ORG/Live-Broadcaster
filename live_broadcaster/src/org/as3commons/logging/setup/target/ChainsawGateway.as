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
	
	import org.as3commons.logging.util.START_TIME;
	import org.as3commons.logging.util.LEVEL_NAMES;
	import org.as3commons.logging.util.SWF_URL;
	
	/**
	 * <code>ChainsawGateway</code> sends events to Chainsaw, a tool from the log4j
	 * platform.
	 * 
	 * <p>To use this class in the setup process one has to refer to
	 * <code>ChainsawTarget</code>.</p>
	 * 
	 * @author Martin Heidegger
	 * @see http://logging.apache.org/chainsaw
	 * @see org.as3commons.logging.setup.target.ChainsawTarget
	 * @since 2.7
	 */
	public final class ChainsawGateway extends XMLSocketGateway {
		
		/** Default host to be used if no host ist passed in */
		public static const DEFAULT_HOST: String = "localhost";
		
		private var _applicationName: String;
		private var _applicationThread: String;
		
		/**
		 * Creates a new <code>ChainsawGateway</code> for sending log events to Chainsaw
		 * 
		 * @param applicationName Name of the application to be provided to Chainsaw
		 * @param applicationThread Thread information to be provided to Chainsaw
		 * @param host Host name on which Chainsaw is running
		 * @param port Port on which Chainsaw is running
		 * @param sendInterval Interval used to send to Chainsaw
		 */
		public function ChainsawGateway(applicationName:String=null, applicationThread:String=null,
										host:String=null, port:int=4448, sendInterval:int=800) {
			super(host||DEFAULT_HOST, port, sendInterval);
			_applicationName = applicationName || "";
			_applicationThread = applicationThread || SWF_URL;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, time:Number, level:int, message:String): void {
			doLog('<log4j:event logger="'+name+'" timestamp="'+(START_TIME+time)+'" level="'+LEVEL_NAMES[level]+'" thread="'+_applicationThread+'" xmlns:log4j="http://jakarta.apache.org/log4j/">'
					+ '<log4j:message><![CDATA['+message.replace(/\<\!\[CDATA\[/gi, "").replace(/\]\]\>/gi, "")+'</log4j:message>'
					+ '<log4j:properties><log4j:data name="application" value="'+_applicationName+'" /></log4j:properties>'
				+ '</log4j:event>');
		}
	}
}