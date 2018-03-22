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
	
	/**
	 * The <code>BufferTarget</code> allows to store log statements for a
	 * unlimited amount of time for a optionally restrictable amount of statements.
	 * 
	 * <p>A common use case for buffer targets is lazy configuration. Just
	 * set a <code>BufferTarget</code> interrim as default target and flush it later to the
	 * target of choice. For example:</p>
	 * 
	 * <listing>
	 *   var buffer: BufferTarget = new BufferTarget();
	 *   
	 *   LOGGER_SETUP.setup = new SimpleTarget(buffer);
	 *   
	 *   // After some loading
	 *   LOGGER_SETUP.setup = ... // your new setup
	 *   
	 *   flushToTarget(buffer.statements);
	 * </listing>
	 * 
	 * @author Martin Heidegger
	 * @since 2.5
	 * @version 2
	 * @see org.as3commons.logging.util#flushToTarget();
	 * @see org.as3commons.logging.util#flushToFactory();
	 */
	public final class BufferTarget implements IAsyncLogTarget {
		
		/** List of logstatements buffered. */
		private var _logStatements:Array /* LogStatement */ = new Array();
		
		/** Holds the length of the log statements */
		private var _length:int = 0;
		
		/** Depth used to introspect objects to store them. */
		private var _introspectDepth:uint;
		
		/** Max amount of statements stored. */
		private var _maxStatements:uint;
		
		/** True if the target should actually introspect and clone the statements */
		private var _clone:Boolean;
		
		/**
		 * Creates a new <code>BufferTarget</code> instance.
		 * 
		 * @param maxStatements Amount of statements stored in this buffer
		 * @param introspectDepth Depth to be used to cache statements, needs to
		 *        be bigger than 0.
		 * @param clone <code>true</code> if the target should actually introspect and clone the statements
		 * @throws Error if introspectDepth is 0;
		 */
		public function BufferTarget(maxStatements:uint=uint.MAX_VALUE,
									 introspectDepth:uint=5,clone:Boolean=true) {
			if(maxStatements == 0){
				throw new Error("Buffer must have a size bigger than 0!");
			}
			_maxStatements = maxStatements;
			_introspectDepth = introspectDepth;
			_clone = clone;
		}
		
		/**
		 * Maximum amount of statements buffered, if the buffer is full, 
		 * the old statements will be dropped
		 */
		public function set maxStatements(max:uint):void {
			_maxStatements=max;
		}
		
		/**
		 * All the statements currently held by the buffer.
		 * This is NOT a copy! If you modify this array you have to call updateLength
		 * to ensure that this buffer continues to work properly;
		 */
		public function get statements():Array {
			return _logStatements;
		}

		/**
		 * Updates the internal length count that is used for performance reasons.
		 */
		public function updateLength():void {
			_length = statements.length;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set introspectDepth(depth:uint): void {
			_introspectDepth=depth;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, params:*,
							person:String, context:String, shortContext:String): void {
			if(_maxStatements == _length) {
				var statement: LogStatement = _logStatements.shift();
				statement.name = name;
				statement.shortName = shortName;
				statement.level = level;
				statement.timeStamp = timeStamp;
				statement.doClone = _clone;
				statement.parameters = params;
				statement.message = message;
				statement.person = person;
				_logStatements[_length-1] = statement;
			} else {
				_logStatements[_length++] =
					new LogStatement(name, shortName, level, timeStamp, message,
										params, person, context, shortContext,
										_introspectDepth, _clone);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear():void {
			_logStatements = [];
			_length = 0;
		}
	}
}
