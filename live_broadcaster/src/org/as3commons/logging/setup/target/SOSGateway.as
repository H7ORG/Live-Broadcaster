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
	
	/**
	 * <code>SOSGateway</code> acts as gateway to channel all requests from <code>
	 * SOSTarget</code> instances to the same server.
	 * 
	 * <p>There is the chance that one might want to use differently formatted
	 * messages in the configuration for the same SOS target. This Gateway is the
	 * separation between "how to access" and "what to send".</p>
	 * 
	 * <p>The Gateway contains fall-back mechanisms if its was temporarily not possible to send
	 * log statements to the targets. (i.e. If the SOS console wasnt started at
	 * the time of the start of the swf)</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.0
	 */
	public final class SOSGateway extends XMLSocketGateway {
		
		/** Default host to be used if none is defined */
		public static const DEFAULT_HOST: String = "localhost";
		
		/**
		 * Constructs a new <code>SOSGateway</code>
		 * 
		 * @param host Host on which the SOS console is running (default: localhost)
		 * @param port Port on which the SOS console is running (default: 4444)
		 */
		public function SOSGateway(host:String = null, port:uint = 4444) {
			super(host||DEFAULT_HOST, port, 200, 1, "!SOS");
		}
		
		/**
		 * Logs a Statement to the SOS Console.
		 * 
		 * @param key
		 * @param message 
		 */
		public function log(key:String, message: String): void {
			message = message.replace(/\<\!\[CDATA\[/gi, "").replace(/\]\]\>/gi, "");
			var linebreak: int = message.indexOf("\n");
			var title: String = null;
			var name: String = "showMessage";
			if( linebreak != -1 ) {
				title = message.substr(0, linebreak) + " ...";
				message = message.substr(linebreak+1);
				name = "showFoldMessage";
			} else if( message.length > 100 ) {
				title = message.substr(0,100) + " ...";
				message = message.substr(100);
				name = "showFoldMessage";
			}
			message = 
				"<" + name+ " key=\"" + key + "\">"
				+ ( title ? "<title><![CDATA[" + title + "]]></title><message>": "")
				+ "<![CDATA[" + message + "]]>" + ( title ? "</message>" : "")
				+ "</"+ name+ ">\n";
			doLog(message);
		}
	}
}