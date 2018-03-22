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
	
	import org.as3commons.logging.api.Logger;
	import org.as3commons.logging.api.ILogSetup;
	
	/**
	 * <code>WrapperRegExpSetup</code> allows regular <code>ILogSetup</code> implementations
	 * to be just executed if a the name and/or the person of the logger that should be "set-up"
	 * to match a regular expression.
	 * 
	 * @author Martin Heidegger
	 * @since 2.6
	 */
	public final class WrapperRegExpSetup implements ILogSetup {
		
		/** Target applied to the loggers. */
		private var _target:ILogSetup;
		
		/** Rule to which the name has to match. */
		private var _nameRule:RegExp;
		
		/** Rule to which the person name has to match. */
		private var _personRule:RegExp;
		
		/**
		 * Constructs a new <code>WrapperRegExpSetup</code> that applies a setup
		 * just if it matches to the passed-in rules.
		 * 
		 * <p>You have to pass in either a rule for the person.</p>
		 * 
		 * @param setup Setup that will be used given the rules match
		 * @param nameRule Rule to which the name has to match for the target to be applied
		 * @param personRule Rule to which the person has to match for the target to be applied
		 * @throws Error if neighter a rule for name nor one for person will be passed in.
		 */
		public function WrapperRegExpSetup(target:ILogSetup, nameRule:RegExp=null,
										  personRule:RegExp=null) {
			_target = target;
			_nameRule = nameRule;
			_personRule = personRule;
			if(!_nameRule && !_personRule) {
				throw new Error("Eighter a class rule or a person rule has to be given");
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function applyTo(logger:Logger): void {
			if(    (!_nameRule  || _nameRule.test(logger.name))
				&& (!_personRule || _personRule.test(logger.person)) ) {
				_target.applyTo(logger);
			}
		}
	}
}
