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
	 * <code>LevelTargetSetup</code> can limit a <code>ILogTarget</code> to be
	 * used just for certain levels.
	 *
	 * @example <listing>
	 *    LOGGER_FACTORY.setup = new LevelTargetSetup(TRACE_TARGET, LogSetupLevel.DEBUG_ONLY );
	 *    // Will trace output just the .debug statements
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2
	 * @see org.as3commons.logging#LOGGER_FACTORY
	 */
	public class LevelTargetSetup implements ILogSetup {
		
		/** Level to set the target to. */
		private var _level:LogSetupLevel;
		
		/** Target which should be used. */
		private var _target:ILogTarget;
		
		/**
		 * Constructs a new <code>LevelTargetSetup</code>.
		 * 
		 * @param target Target which should be receiving the log output.
		 * @param level Level at which the target should be receiving the output.
		 */
		public function LevelTargetSetup(target:ILogTarget, level:LogSetupLevel) {
			_target = target;
			_level = level;
		}
		
		/**
		 * @inheritDoc
		 */
		public function applyTo(logger:Logger):void {
			_level.applyTo(logger, _target);
		}
	}
}
