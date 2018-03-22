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
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.api.ILogSetup;
	import org.as3commons.logging.api.Logger;
	
	/**
	 * <code>SimpleRegExpSetup</code> allows to apply targets just in certain caes. 
	 * 
	 * <listing>
	 *    // Only trace statements by martin or christophe
	 *    LOGGER_FACTORY.setup = new SimpleRegExpSetup(TRACE_TARGET,null,/^(Martin|Christophe)$/);
	 *    
	 *    // Only trace statements that start with org.as3commons.
	 *    LOGGER_FACTORY.setup = new SimpleRegExpSetup(TRACE_TARGET,/^org\.as3commons\./);
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 */
	public final class SimpleRegExpSetup implements ILogSetup {
		
		/** Target applied to the loggers. */
		private var _target:ILogTarget;
		
		/** Rule to which the name has to match. */
		private var _nameRule:RegExp;
		
		/** Rule to which the person name has to match. */
		private var _personRule:RegExp;
		
		/** Level to which the setup will be passed */
		private var _level:LogSetupLevel;
		
		/**
		 * Constructs a new <code>SimpleRegExpSetup</code> that passes a level
		 * just if it matches to the passed-in rules.
		 * 
		 * <p>You have to pass in eighter a rule for the person to match or the
		 * name to match.</p>
		 * 
		 * @param target Target to be used.
		 * @param nameRule Rule to which the name has to match for the target to be applied
		 * @param personRule Rule to which the person has to match for the target to be applied
		 * @param level Level to which the target should be applied (default=ALL levels);
		 * @throws Error if neighter a rule for name nor one for person will be passed in.
		 */
		public function SimpleRegExpSetup(target:ILogTarget, nameRule:RegExp=null,
										  personRule:RegExp=null, level:LogSetupLevel=null) {
			_target = target;
			_nameRule = nameRule;
			_personRule = personRule;
			_level = level||LogSetupLevel.ALL;
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
				_level.applyTo(logger, _target);
			}
		}
	}
}
