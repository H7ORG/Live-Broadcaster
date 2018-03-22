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
	import org.flexunit.runner.notification.RunListener;
	import org.flexunit.runner.notification.IRunListener;
	import org.flexunit.reporting.FailureFormatter;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.flexunit.runner.IDescription;
	import org.flexunit.runner.Result;
	import org.flexunit.runner.notification.Failure;
	
	/**
	 * This listener sends log statements produced by the FlexUnit framework
	 * to the as3commons logging system.
	 * 
	 * <listing>
	 *   LOGGER_FACTORY.setup = new SimpleTargetSetup( new TraceTarget( "{logLevel} {message}") );
	 *   
	 *   var core: FlexUnitCore = new FlexUnitCore();
	 *   core.addListener( new FlexUnitListener() );
	 * </listing>
	 * 
	 * <p>The implementation uses two loggers, one of the person "Status" and one
	 * of the person "Result".</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5.2
	 * @see http://opensource.adobe.com/wiki/display/flexunit/FlexUnit
	 */
	public final class FlexUnitListener extends RunListener implements IRunListener {
		
		private static const statusLogger: ILogger = getLogger( FlexUnitListener, "Status" );
		private static const resultLogger: ILogger = getLogger( FlexUnitListener, "Result" );
		
		/**
		 * @inheritDoc
		 */
		override public function testRunFinished( result:Result ):void {
			var time: String = String( result.runTime / 1000 ) + "s";
			if( result.successful ) {
				resultLogger.info( "Time: {}", time );
				resultLogger.info( "OK ( {runCount} test{s})",
					{runCount: result.runCount, s: result.runCount==0 ? "" : "s"} );
			} else {
				resultLogger.error( "Time: {}", time );
				resultLogger.error( "FAILURES!!! Tests run: {runCount}, {failureCount} Failures.", result );
				
				var failures: Array = result.failures;
				const failureCount: int = failures.length; 
				
				//Determine if there are any failures to print
				if (failureCount == 1) {
					resultLogger.error( "There was 1 failure:" );
				} else {
					resultLogger.error( "There were {} failures:", failures.length );
				}
				
				//Print each failure
				for ( var i:int=0; i<failureCount; ++i ) {
					resultLogger.error(
						"{prefix} {failure.testHeader} {failure.stackTrace}",
						{ prefix: i+1, failure: failures[i] }
					);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function testStarted( description:IDescription ):void {
			statusLogger.info( "{} started", description.displayName );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function testFailure( failure:Failure ):void {
			//Determine if the exception in the failure is considered an error
			if ( FailureFormatter.isError( failure.exception ) ) {
				statusLogger.fatal( "{description.displayName} threw an exception: {exception}", failure );
			} else {
				statusLogger.error( "{description.displayName} assertion failed: {message}", failure );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function testIgnored( description:IDescription ):void {
			statusLogger.warn( description.displayName );
		}
	}
}
