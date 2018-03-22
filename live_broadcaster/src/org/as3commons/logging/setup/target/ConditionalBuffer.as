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
	
	import org.as3commons.logging.api.LoggerFactory;
	import org.as3commons.logging.api.ILogTarget;
	import org.as3commons.logging.util.passToFactory;
	import org.as3commons.logging.util.passToTarget;
	
	/**
	 * A <code>ConditionalBuffer</code> stores statements sent to it until a certain
	 * condition is met. In that case it will forward all stored statements to
	 * the defined target.
	 * 
	 * <p>As target a <code>ILogTarget</code> or a <code>LoggerFactory</code>
	 * is an option.</p>
	 * 
	 * <p>This is a abstract class. Use implementations like <code>FatalBuffer</code>.
	 * They override the <code>test</code> method to implement conditions.</p>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @see org.as3commons.logging.setup.target.FatalBuffer
	 */
	public class ConditionalBuffer implements IAsyncLogTarget {
		
		/** Buffered statements. */
		private const _buffer:BufferTarget = new BufferTarget();
		
		/** Target to be adressed. */
		private var _logTarget:ILogTarget;
		
		/** Factory to be adressed. */
		private var _logFactory:LoggerFactory;
		
		/**
		 * Constructs a new <code>ConditionalBuffer</code> instance.
		 * 
		 * @param target Target that should receive the log statements.
		 * @param maxStatements Max amount of statements to be buffered.
		 */
		public function ConditionalBuffer(target:*,
											maxStatements:uint=uint.MAX_VALUE,
											introspectDepth:uint=5) {
			_buffer.maxStatements = maxStatements;
			_buffer.introspectDepth = introspectDepth;
			this.target = target;
		}
		
		/**
		 * Target to be called with all the buffered statements, once the 
		 * condition has been reached.
		 */
		public function set target(target:*):void {
			if( target is ILogTarget ) {
				this.logTarget = target;
			} else {
				this.logFactory = target;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function set introspectDepth(depth:uint): void {
			_buffer.introspectDepth = depth;
		}
		
		/**
		 * @copy BufferTarget#maxStatements
		 */
		public function set maxStatements(maxStatements:uint): void {
			_buffer.maxStatements = maxStatements;
		}
		
		/**
		 * <code>ILogTarget</code> to be called with all the buffered statements, once the 
		 * condition has been reached.
		 */
		public function set logTarget(logTarget:ILogTarget):void {
			_logTarget = logTarget;
			_logFactory = null;
		}
		
		/**
		 * <code>LoggerFactory</code> to be called with all the buffered statements, once the 
		 * condition has been reached.
		 */
		public function set logFactory(logFactory:LoggerFactory):void {
			_logTarget = null;
			_logFactory = logFactory;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameter:*,
							person:String, context:String, shortContext:String): void {
			
			_buffer.log(name, shortName, level, timeStamp, message, parameter,
						person, context, shortContext);
			
			if( test(name, shortName, level, timeStamp, message, parameter,
						person, context, shortContext) ) {
				if( _logTarget ) {
					passToTarget(_buffer.statements, _logTarget);
				} else {
					passToFactory(_buffer.statements, _logFactory);
				}
				_buffer.clear();
			}
		}
		
		/**
		 * Tests the 
		 * 
		 * @param name Name of the logger that triggered the log statement.
		 * @param shortName Shortened form of the name.
		 * @param level Level of the log statement that got triggered.
		 * @param timeStamp Time stamp of when the log statement got triggered.
		 * @param message Message of the log statement.
		 * @param parameters Parameters for the log statement.
		 * @param person Information about the person that filed this log statement.
		 */
		protected function test(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameter:*,
							person:String, context:String, shortContext:String):Boolean {
			return false;
			name; shortName; level; timeStamp; message; person; parameter; context;
			shortContext;
		}
	}
}
