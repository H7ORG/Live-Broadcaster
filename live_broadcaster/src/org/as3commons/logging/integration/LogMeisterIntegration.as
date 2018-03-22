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
package org.as3commons.logging.integration {
	
	import logmeister.connectors.ILogMeisterConnector;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getNamedLogger;
	
	import flash.system.Capabilities;
	
	/**
	 * This integration passes messages to the LogMeister framework on to the
	 * as3commons framework. 
	 * 
	 * <listing>
	 *   import org.as3commons.logging.integration.LogMeisterIntegration;
	 *   import logmeister.LogMeister;
	 *   
	 *   LogMeister.addLogger( new LogMeisterIntegration() );
	 * </listing>
	 * 
	 * <p>Since LogMeister uses a different approach to evaluate which method the
	 * log statements are coming from, the path has to be evaluated. This costs
	 * time so we added a switch to use it optionally</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5.2
	 * @see http://github.com/base42/LogMeister
	 * @see org.as3commons.logging.setup.target.LogMeisterTarget
	 */
	public final class LogMeisterIntegration implements ILogMeisterConnector {
		
		/** true allows object evaluation */
		private var _evaluateClass: Boolean;
		
		/**
		 * Constructs a new LogMeisterIntegration.
		 * 
		 * @param evaluate If true it tries to evaluate from which class it was sent
		 */
		public function LogMeisterIntegration(evaluate:Boolean=true) {
			_evaluateClass = evaluate;
		}
		
		/**
		 * Satisfies the interface
		 */
		public function init():void {}
		
		/**
		 * <code>true</code> to evaluate the location via a exception in a debug player.
		 */
		public function set evaluateClass(bool: Boolean):void{
			_evaluateClass = bool;
		}
		
		public function get evaluateClass(): Boolean {
			return _evaluateClass;
		}
		
		/**
		 * Sends a critical message as "fatal" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendCritical(...args:Array):void {
			logger.fatal(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Sends a debug message as "debug" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendDebug(...args:Array):void {
			logger.debug(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Sends a error message as "error" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendError(...args:Array):void {
			logger.error(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Sends a fatal message as "fatal" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendFatal(...args:Array):void {
			logger.fatal(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Sends a info message as "info" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendInfo(...args:Array):void {
			logger.info(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Sends a notice message as "info" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendNotice(...args:Array):void {
			logger.info(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Sends a status message as "info" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendStatus(...args:Array):void {
			logger.info(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Sends a warn message as "warn" message to the as3commons framework
		 * @param args Message and parameters, sent to the logger
		 */
		public function sendWarn(...args:Array):void {
			logger.warn(args[0], args.length > 1 ? args.splice(1) : null);
		}
		
		/**
		 * Evaluates the logger to be used
		 * 
		 * @return A logger matching to the statement
		 */
		private function get logger():ILogger {
			var name: String = "";
			if(Capabilities.isDebugger && _evaluateClass) {
				var error: Error = new Error();
				var stackTrace: String = error.getStackTrace();
				if( stackTrace ) {
					// just in debug player
					var nextLine: int = stackTrace.indexOf("\n",
						stackTrace.indexOf("\n",
							stackTrace.indexOf("\n",
								stackTrace.indexOf("\n",
									stackTrace.indexOf("\n",
										stackTrace.indexOf("\n",
											stackTrace.indexOf("\n")
										+1)
									+1)
								+1)
							+1)
						+1)
					+1);
					name = stackTrace.substring(nextLine+5, stackTrace.indexOf("/", nextLine+1));
					name = name.replace("::", ".");
				}
			}
			return getNamedLogger(name, "LogMeister");
		}
	}
}
