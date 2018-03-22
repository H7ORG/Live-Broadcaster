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
package org.as3commons.logging.setup {
	import org.as3commons.logging.api.ILogSetup;
	import org.as3commons.logging.api.Logger;

	/**
	 * @author Martin Heidegger
	 * @since 2.6
	 * @see org.as3commons.logging.setup#mergeSetups()
	 */
	public class MergedSetup implements ILogSetup {
		
		private var _logSetupA:ILogSetup;
		private var _logSetupB:ILogSetup;
		private var _mergedSetup:MergedSetup;
		
		/**
		 * Constructs a new <code>MergedSetup</code> that applies both
		 * <code>ILogSetup</code>s .
		 * 
		 * @param logTargetA First <code>ILogSetup</code> to be applied.
		 * @param logTargetB Second <code>ILogSetup</code> to be applied.
		 * @throws Error if one of both setups in null
		 */
		public function MergedSetup(logSetupA:ILogSetup, logSetupB:ILogSetup) {
			if(!logSetupA || !logSetupB) throw new Error("Both setups need to be defined");
			_logSetupA = logSetupA;
			_mergedSetup = logSetupB as MergedSetup;
			_logSetupB = logSetupB;
		}
		
		/**
		 * @inheritDoc
		 */
		public function applyTo(logger:Logger):void {
			_logSetupA.applyTo(logger);
			var target:MergedSetup = this;
			while (target._mergedSetup) {
				target = target._mergedSetup;
				target._logSetupA.applyTo(logger);
			};
			target._logSetupB.applyTo(logger);
		}
		
		/**
		 * Inserts all targets of this MergedSetup into a position of an array
		 * (performance *yey*)
		 */
		internal function insertSetups(array:Array, pos:int):void {
			array.splice(pos,0,_logSetupA,_logSetupB);
			var target:MergedSetup = this;
			while (target._mergedSetup) {
				target = target._mergedSetup;
				array.splice(++pos,0,_logSetupA);
			}
		}
	}
}
