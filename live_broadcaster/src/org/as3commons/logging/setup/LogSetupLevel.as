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
	import org.as3commons.logging.api.Logger;
	
	/**
	 * <code>LogSetupLevel</code>, in contrary to the <code>LogLevel</code>, can
	 * is made to allow certain levels to be activated/deactivated.
	 * 
	 * <p>Levels are defined by a integer value. Different values can be combined
	 * by using the <code>.or()</code> method.</p>
	 * 
	 * <listing>var debugAndErrorOutput:LogSetupLevel = LogSetupLevel.DEBUG_ONLY.or(LogSetupLevel.ERROR_ONLY);</listing>
	 *
	 * @author Martin Heidegger
	 * @since 2
	 * @see org.as3commons.logging.setup.LevelTargetSetup
	 */
	public final class LogSetupLevel {
		
		/** Storage for already created levels. */
		private static const _levels:Array = [];
		
		/** Level that will not log any level. */
		public static const NONE:LogSetupLevel       = getLevelByValue( 0x0001 );
		
		/** Level that will log just the fatal statements. */
		public static const FATAL_ONLY:LogSetupLevel = getLevelByValue( 0x0002 );
		
		/** Level that will log just the fatal statements. */
		public static const FATAL:LogSetupLevel      = NONE.or( FATAL_ONLY );
		
		/** Level that will log just the error statements. */
		public static const ERROR_ONLY:LogSetupLevel = getLevelByValue( 0x0004 );
		
		/** Level that will log the error or fatal statements. */
		public static const ERROR:LogSetupLevel      = FATAL.or( ERROR_ONLY );
		
		/** Level that will log just the warn statements. */
		public static const WARN_ONLY:LogSetupLevel  = getLevelByValue( 0x0008 );
		
		/** Level that will log the error, fatal or warn statements. */
		public static const WARN:LogSetupLevel       = ERROR.or( WARN_ONLY );
		
		/** Level that will log just the info statements. */
		public static const INFO_ONLY:LogSetupLevel  = getLevelByValue( 0x0010 );
		
		/** Level that will log the error, fatal, warn or info statements. */
		public static const INFO:LogSetupLevel       = WARN.or( INFO_ONLY );
		
		/** Level that will log just the debug statements. */
		public static const DEBUG_ONLY:LogSetupLevel = getLevelByValue( 0x0020 );
		
		/** Level that will log all statements. */
		public static const DEBUG:LogSetupLevel      = INFO.or( DEBUG_ONLY );
		
		/** Level that will log all statements. */
		public static const ALL:LogSetupLevel        = DEBUG;
		
		/**
		 * Returns a <code>LogSetupLevel</code> for the value.
		 * 
		 * @param value Value of the requested <code>LogSetupLevel</code>.
		 * @return <code>LogSetupLevel</code> matching to the value.
		 */
		public static function getLevelByValue(value:int):LogSetupLevel {
			return _levels[value] || ( _levels[value] = new LogSetupLevel(value) );
		}
		
		private var _value:int;
		
		/**
		 * Creates a new setup level instance.
		 * 
		 * @param value Value of the log level.
		 * @throws Error if the level for that value was already created before.
		 */
		public function LogSetupLevel(value:int) {
			if( _levels[value] ) {
				throw Error( "LogTargetLevel exists already!" );
			}
			_levels[value] = this;
			_value = value;
		}
		
		/**
		 * Applies the passed-in target to the passed-in logger for all levels
		 * matching to this <code>LogSetupLevel</code>.
		 * 
		 * @param logger <code>Logger</code> instance to receive the targets
		 * @param target <code>ILogTarget</code> that should be used for the defined targets
		 */
		public function applyTo(logger:Logger, target:ILogTarget):void {
			if(_value & DEBUG_ONLY._value) logger.debugTarget = target;
			if(_value & INFO_ONLY._value)  logger.infoTarget  = target;
			if(_value & WARN_ONLY._value)  logger.warnTarget  = target;
			if(_value & ERROR_ONLY._value) logger.errorTarget = target;
			if(_value & FATAL_ONLY._value) logger.fatalTarget = target;
		}
		
		/**
		 * Combines this level with another one, allowing to output to either of both
		 * levels.
		 *
		 * @param otherLevel <code>LogSetupLevel</code> that should be used.
		 * @return Resulting level that allows either of the levels.
		 */
		public function or(otherLevel:LogSetupLevel):LogSetupLevel {
			return getLevelByValue( _value | otherLevel._value );
		}
		
		/**
		 * Value of this level.
		 * 
		 * @return level of this logger
		 */
		public function valueOf():int {
			return _value;
		}
	}
}
