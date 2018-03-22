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
	
	/**
	 * Added as <i>Progression 4</i> target this function will send Progression
	 * log events to the as3commons system.
	 * 
	 * <listing>
	 *   import jp.nium.core.debug.Logger;
	 *   
	 *   Logger.enabled = true;
	 *   Logger.loggingFunction = Progression4Integration;
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 */
	public function Progression4Integration( ...messages: Array ): void {
		var message: String;
		var level: String;
		if( messages.length == 3 ) {
			level = messages[1];
			message = messages[2];
		} else if( messages.length == 2 ){
			level = messages[0];
			message = messages[1];
		} else {
			message = messages[0];
		}
		if( level == "  [warn]" ) {
			logger.warn( message );
		} else if( level == "  [error]" ) {
			logger.error( message );
		} else if( level == "  [info]" ) {
			logger.info( message );
		} else {
			logger.debug( message );
		}
	}
}

import jp.nium.core.debug.Logger;
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;


const logger: ILogger = getLogger( Logger, "Progression" );