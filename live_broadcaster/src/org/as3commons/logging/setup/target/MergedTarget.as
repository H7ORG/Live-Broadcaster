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
	
	import org.as3commons.logging.api.ILogTarget;
	
	/**
	 * <code>MergedTarget</code> routes a log statement to two <code>ILogTarget</code>s.
	 * 
	 * <p>The logging process assumes that just one logging target will receive
	 * log statements. To have two targets to receive the log statements you can
	 * use this class.</p>
	 * 
	 * <listing>
	 *    LOGGER_FACTORY.setup = new SimpleTargetSetup( new MergedTarget( TRACE_TARGET, new SOSTarget ) );
	 *    // Will output the content to trace and to SOS
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2
	 * @version 2
	 * @see org.as3commons.logging.setup.target#mergeTargets()
	 */
	public final class MergedTarget implements ILogTarget {
		
		private var _logTargetA:ILogTarget;
		private var _logTargetB:ILogTarget;
		private var _mergedTarget:MergedTarget;
		
		/**
		 * Constructs a new <code>MergedTarget</code> out of two <code>ILogTarget</code>s.
		 * 
		 * @param logTargetA First <code>ILogTarget</code> to log to.
		 * @param logTargetB Second <code>ILogTarget</code> to log to.
		 * @throws Error if one of both targets in null
		 */
		public function MergedTarget(logTargetA:ILogTarget, logTargetB:ILogTarget) {
			_logTargetA = logTargetA;
			_logTargetB = logTargetB;
			_mergedTarget = logTargetB as MergedTarget;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:*,
							person:String, context:String, shortContext:String): void {
			_logTargetA.log(name, shortName, level, timeStamp, message, parameters,
							person, context, shortContext);
			var target:MergedTarget = this;
			while (target._mergedTarget) {
				target = target._mergedTarget;
				target._logTargetA.log(name, shortName, level, timeStamp, message,
										parameters, person, context, shortContext);
			};
			target._logTargetB.log(name, shortName, level, timeStamp, message,
									parameters, person, context, shortContext);
		}
		
		/**
		 * Inserts all targets of this MergedTarget into a position of an array
		 * (performance *yey*)
		 */
		internal function insertTargets(array:Array, pos:int):void {
			array.splice(pos,0,_logTargetA,_logTargetB);
			var target:MergedTarget = this;
			while (target._mergedTarget) {
				++pos;
				target = target._mergedTarget;
				array.splice(pos,0,_logTargetA);
			}
		}
	}
}
