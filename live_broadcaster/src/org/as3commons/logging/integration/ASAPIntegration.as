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
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getNamedLogger;
	import org.asaplibrary.util.debug.Log;
	import org.asaplibrary.util.debug.LogEvent;
	
	/**
	 * <code>ASAPLibrary</code> is a integration Hook for the ASAP Library that
	 * can be used to redirect ASAP log statements to as3commons logging.
	 * 
	 * <listing>
	 *   import org.asaplibrary.util.debug.Log;
	 *   
	 *   Log.addLogListener( ASAPIntegration );
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see http://asaplibrary.org
	 * @see org.as3commons.logging.setup.target.ASAPTarget
	 */
	public function ASAPIntegration( event:LogEvent ):void {
		var nameStr: String = event.sender.replace("::",".");
		var logger: ILogger = _cache[ nameStr ] || ( _cache[ nameStr ] = getNamedLogger( nameStr, "asap" ) );
		switch( event.level ) {
			case Log.LEVEL_DEBUG:
				logger.debug( event.text );
				break;
			case Log.LEVEL_STATUS:
			case Log.LEVEL_INFO:
				logger.info( event.text );
				break;
			case Log.LEVEL_WARN:
				logger.warn( event.text );
				break;
			case Log.LEVEL_ERROR:
				logger.error( event.text );
				break;
			case Log.LEVEL_FATAL:
				logger.fatal( event.text );
				break;
		}
	}
}

const _cache: Object = {};