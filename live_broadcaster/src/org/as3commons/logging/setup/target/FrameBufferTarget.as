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
	
	import flash.events.Event;
	import org.as3commons.logging.api.ILogTarget;
	
	import flash.display.Shape;
	
	/**
	 * <code>FrameBufferTarget</code> limits the amount of log statements that
	 * get written to another log target per frame.
	 * 
	 * <p>If you log too many statements in too short time they block the single-threaded
	 * Flash system. To prevent that you can use this <code>FrameBufferTarget</code>.</p>
	 * 
	 * <p>This <code>FrameBufferTarget</code> acts as a wrapper to any <code>ILogTarget</code>.
	 * It just allows a certain amount of log statements per frame. If more statements
	 * that the defined limit gets triggered they will be stored in a cache and be triggered
	 * in the next <code>EnterFrame</code> event.</p>
	 * 
	 * @author Martin Heidegger
	 * @version 2.0
	 */
	public class FrameBufferTarget implements IAsyncLogTarget {
		
		/**
		 * Buffers that are supposed to be cleared.
		 */
		private static const _buffers:Array /* FrameBufferTarget */ = [];
		
		/**
		 * Keeps record of how many levels to introspect
		 */
		private var _introspectDepth:uint = uint.MAX_VALUE;
		
		/**
		 * Clears the buffers that should be cleared (called onEnterFrame)
		 * 
		 * @param event Unavoidable event from adobes event system.
		 */
		private static function clearBuffers(event:Event): void {
			for( var index: int = _buffers.length-1; index > -1; --index ) {
				if( FrameBufferTarget( _buffers[index] ).flush() ) {
					_buffers.splice( index, 1 );
				}
			}
		}
		
		/** Internal shape used for the <code>EnterFrame</code> event. */
		private static const _shape: Shape = new Shape();
		{
			// Registers the clearBuffers method to a ENTER_FRAME Event
			_shape.addEventListener( Event.ENTER_FRAME, clearBuffers );
		}
		
		/** Buffered statements. */
		private const _bufferedStatements:Array /* BufferStatement */ = [];
		
		/** Target to flush to */
		private var _target:ILogTarget;
		
		/** Statements that should be triggered max. per frame. */
		private var _statementsPerFrame:int;
		
		/** Statements that were triggered this frame. */
		private var _statementsThisFrame:int = 0;
		
		/** Holds <code>true</code> if the buffer is registered to be cleared. */
		private var _isRegistered:Boolean;
		
		/** The length of the buffer */
		private var _bufferLength: uint = 0;
		
		/**
		 * Constructs a new <code>FrameBufferTarget</code>.
		 * 
		 * @param target Target to log the statements to.
		 * @param statementsPerFrame Amount of statements triggered per frame.
		 */
		public function FrameBufferTarget(target:ILogTarget, statementsPerFrame:int) {
			_target = target;
			_statementsPerFrame = statementsPerFrame;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameter:*,
							person:String, context:String, shortContext:String):void {
			// Only log it if the statements this frame do not yet exceed
			// the max statements that can be triggered per frame
			if( _statementsThisFrame < _statementsPerFrame ) {
				_target.log(name, shortName, level, timeStamp, message, parameter,
							person, context, shortContext);
				++_statementsThisFrame;
			} else {
				_bufferedStatements[_bufferLength++] =
					new LogStatement(name, shortName, level, timeStamp, message,
									parameter, person, context, shortContext,
									_introspectDepth);
			}
			
			if( !_isRegistered ) {
				// Even if the buffer ain't full, it has to set 
				_isRegistered = true;
				_buffers.push( this );
			}
		}
		
		/**
		 * Flushes the buffered statements.
		 * 
		 * @return true if all statements have been flushed
		 */
		private function flush(): Boolean {
			for( var i: int = _statementsPerFrame-1; i>-1; --i ) {
				var statement: LogStatement = _bufferedStatements.shift();
				--_bufferLength;
				if( statement ) {
					_target.log(statement.name, statement.shortName, statement.level,
							statement.timeStamp, statement.message, statement.parameters,
							statement.person, statement.context, statement.shortContext);
				} else {
					break;
				}
			}
			if( _bufferLength == 0 ) {
				_statementsThisFrame = 0;
				// stores that its not registered anymore.
				_isRegistered = false;
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function set introspectDepth(depth:uint):void {
			_introspectDepth = depth;
		}
	}
}
