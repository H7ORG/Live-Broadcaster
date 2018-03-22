package org.igazine.nativeprocess.encoder {

/**
 * 
 * Live Broadcaster
 * Live Streaming Software for Mac / Windows
 * Project Copyright (c) 2014 - 2017 Yatko (LLC) and Kalman Venczel
 * File/Lib Copyright (c) 2017 Tamas Sopronyi & Yatko (LLC)
 * Licensed under GNU General Public License v3.0, with Runtime Library Exception
 * This source file is part of the cameleon.live project - https://www.cameleon.live
 * 
 * See https://app.h7.org/cameleon/ for project information and documentation
 * See https://app.h7.org/cameleon/LICENSE.txt for license information
 * See https://app.h7.org/cameleon/CONTRIBUTORS.txt for list of project authors
 *  
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 * 
 */
 
/**
 * 
 * ActionScript file
 * Copyright (c) 2017 Tamas Sopronyi & Yatko (LLC)
 * Author: Tamas Sopronyi, 2017
 * 
 */
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.errors.EOFError;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.Timer;
	import mx.utils.UIDUtil;
	import org.igazine.managers.FFMPEGManager;
	import org.igazine.nativeprocess.encoder.inputs.FInput;
	import org.igazine.nativeprocess.encoder.inputs.IPipe;
	import org.igazine.nativeprocess.encoder.outputs.FOutput;
	import org.igazine.nativeprocess.events.FFMPEGEvent;
	
	public class FFMPEG extends EventDispatcher {
		
		public static var TIMEOUT:int = 30;
		public static var MAX_DEBUG_LENGTH:int = 10000;
		public static var NUM_RETRIES:int = 3;
		
		private var process:NativeProcess;
		private var processInfo:NativeProcessStartupInfo;
		private var args:Vector.<String>;
		private var outputs2:Array = new Array();
		private var inputs2:Array = new Array();
		private var outputFrameRate:int = 25;
		private var errorOutputString:String;
		private var hasFrame:Boolean;
		private var connectionTimer:Timer;
		private var hasInputCodecOptions:Boolean;
		private var tempBA:ByteArray = new ByteArray();
		private var numOutputsSent:int = 0;
		private var numBytesSent:int = 0;
		private var minNumBytesSent:int = 128000;
		private var stdOutEnabled:Boolean = true;
		private var currentRetry:int = 0;
		private var hasStandardInput:Boolean;
		private var silenceBytes:ByteArray;
		private var silenceTimer:Timer;
		private var numStreamClients:int;
		
		//
		// Global FFMPEG options
		//
		private var _stdin:Boolean = false;
		private var _overwriteFiles:Boolean = false;
		private var _stats:Boolean = true;
		private var _logLevel:String = FFMPEGDebugLevel.INFO;
		private var _threads:int;
		private var _threadQueueSize:int = 512;
		private var _enableLogging:Boolean;
		private var _dataBytes:ByteArray = new ByteArray();
		
		public var uid:String;
		public var cameraId:String = "";
		public var inputVideoCodec:String = "";
		//public var inputVideoResolution:String = "";
		public var inputVideoWidth:int;
		public var inputVideoHeight:int;
		private var enableRetry:Boolean = false;
		public var disableRetry:Boolean;
		
		public function FFMPEG( executable:File ) {
			
			super( );
			
			if ( !NativeProcess.isSupported ) {
				
				throw new IllegalOperationError( "NativeProcess is not supported!" );
				return;
				
			}
			
			uid = UIDUtil.createUID();
			
			args = new Vector.<String>;
			processInfo = new NativeProcessStartupInfo();
			processInfo.executable = executable;
			process = new NativeProcess();
			addListeners();
			
			silenceBytes = new ByteArray();
			for ( var i:int = 0; i < 8000; i++ ) silenceBytes.writeByte( 0 );
			
			FFMPEGManager.addProcess( this );
			
		}
		
		//
		// Static getters
		//
		
		public static function get isMac():Boolean {
			
			return ( Capabilities.os.search( "Mac OS" ) >= 0 );
			
		}
		
		
		//
		// Private functions
		//
		
		private function standardErrorData( e:ProgressEvent ):void {
			
			errorOutputString = process.standardError.readUTFBytes( process.standardError.bytesAvailable );
			
			//trace( '----------------- version', FFMPEGOutputPattern.VERSION.test( errorOutputString ) );
			//trace( '----------------- VIDEO_STREAM_0_RESOLUTION', FFMPEGOutputPattern.VIDEO_STREAM_0_RESOLUTION.exec( errorOutputString ) );
			
			var dispatch:Boolean = true;
			
			for ( var i:int = 0; i < FFMPEGOutputPattern.IGNOREDS.length; i++ ) {
				
				if ( errorOutputString.search( FFMPEGOutputPattern.IGNOREDS[i] ) >= 0 ) return;
				
			}
			
			if ( FFMPEGOutputPattern.VERSION.test( errorOutputString ) ) {
				
				var evt:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.INIT );
				evt.data = errorOutputString;
				this.dispatchEvent( evt );
				
			}
			
			if ( FFMPEGOutputPattern.FRAME.test( errorOutputString ) ) {
				
				dispatch = false;
				
				if ( !hasFrame ) {
					
					var initEvt:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.START );
					this.dispatchEvent( initEvt );
					hasFrame = true;
					enableRetry = true;
					
					if ( connectionTimer ) {
						
						connectionTimer.stop();
						connectionTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
						connectionTimer = null;
						
					}
					
					
				}
				
				var frameEvent:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.INPUT_FRAME );
				frameEvent.data = errorOutputString;
				this.dispatchEvent( frameEvent );
				
			}
			
			if ( FFMPEGOutputPattern.VIDEO_STREAM_0_TYPE.test( errorOutputString ) ) {
				
				if ( !hasInputCodecOptions ) {
				
					var codecObj:Object = FFMPEGOutputPattern.VIDEO_STREAM_0_TYPE.exec( errorOutputString );
					dispatchOutput( 'codecObj: ' + codecObj );
					inputVideoCodec = String( codecObj[0] );
					dispatchOutput( 'inputVideoCodec:' + inputVideoCodec );
					
					var resObj:Object = FFMPEGOutputPattern.VIDEO_STREAM_0_RESOLUTION.exec( errorOutputString );
					dispatchOutput( 'resObj: ' + resObj );
					inputVideoResolution = String( resObj[0] );
					dispatchOutput( 'inputVideoResolution:' + inputVideoWidth + "x" + inputVideoHeight );
					
					var videoStreamEvent:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.VIDEO_STREAM_FOUND );
					this.dispatchEvent( videoStreamEvent );
					
					hasInputCodecOptions = true;
					
				}
				
			}
			
			if ( dispatch ) {
				
				dispatchOutput( errorOutputString );
				
			}
			
		}
		
		private function set inputVideoResolution( s:String ):void {
			
			var a:Array = s.split( "x" );
			inputVideoWidth = int( a[0] );
			inputVideoHeight = int( a[1] );
			
		}
		
		private function dispatchOutput( outputString:String ):void {
			
			var evt:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.ERROR_OUTPUT );
			evt.data = outputString;
			this.dispatchEvent( evt );
			
		}
		
		private function standardInputProgress( e:ProgressEvent ):void {
			
			this.dispatchEvent( e );
			
		}
		
		private function standardOutputData( e:ProgressEvent ):void {
			
			try {
				
				this.standardOutput.readBytes( _dataBytes, _dataBytes.length );
				//trace( "FFMPEG._dataBytes.length", _dataBytes.length );
				this.dispatchEvent( new Event( FFMPEGEvent.DATA_AVAILABLE ) );
				
			} catch (e:EOFError ) {}
			
		}
		
		private function processExit( e:NativeProcessExitEvent ):void {
			
			dispatchOutput( 'processExit: ' + e.exitCode + '| enableRetry: ' + enableRetry );
			
			if ( enableRetry && !disableRetry && ( e.exitCode != 0 ) && ( currentRetry < NUM_RETRIES ) ) {
				
				this.dispatchEvent( new FFMPEGEvent( FFMPEGEvent.RETRY ) );
				restart();
				
			} else {
				
				var evt:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.EXIT );
				evt.exitCode = e.exitCode;
				this.dispatchEvent( evt );
				dispose();
				FFMPEGManager.removeProcess( this );
				
			}
			
		}
		
		private function processIOError( e:IOErrorEvent ):void {
			
			//this.dispatchEvent( e );
			
		}
		
		
		private function setupArguments():void {
			var i:int;
			var j:int;
			var v:Vector.<String>;
			
			args = new Vector.<String>;
			
			//
			// Processing global options
			//
			
			( _stats ) ? args.push( "-stats" ) : args.push( "-nostats" );
			//( _stdin ) ? args.push( "-stdin" ) : args.push( "-nostdin" );
			( _overwriteFiles ) ? args.push( "-y" ) : args.push( "-n" );
			if ( _enableLogging ) args.push( "-report" );
			
			if ( _threads > 0 ) {
				args.push( "-threads" );
				args.push( String( _threads ) );
			}
			
			args.push( "-loglevel" );
			args.push( _logLevel );
			
			args.push( "-thread_queue_size", _threadQueueSize );
			
			for ( i = 0; i < inputs2.length; i++ ) {
				args = args.concat( inputs2[i].parameters );
			}
			
			for ( i = 0; i < outputs2.length; i++ ) {
				args = args.concat( outputs2[i].parameters );
			}
			
			processInfo.arguments = args;
		}
		
		//
		// Public functions
		//
		
		public function start():void {
			
			this.dispatchEvent( new Event( Event.INIT ) );
			setupArguments();
			dispatchOutput( String( args ) );
			
			if ( connectionTimer ) {
				
				connectionTimer.stop();
				connectionTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
				connectionTimer = null;
				
			}
			
			connectionTimer = new Timer( TIMEOUT * 1000, 1 );
			connectionTimer.addEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
			connectionTimer.start();
			
			process.start( processInfo );
			if ( hasStandardInput ) startStandardInputProcessing();
			
		}
		
		/** 
		* Typical format of a simple multiline comment. 
		* This text describes the myMethod() method, which is declared below. 
		* 
		* @tag Tag text.
		* 
		* @param param1 Describe param1 here. 
		* @param param2 Describe param2 here. 
		* 
		* @return Describe return value here. 
		* 
		* @see someOtherMethod 
		*/ 
		
		public function execute( params:Vector.<String> ):void {
			
			this.dispatchEvent( new Event( Event.INIT ) );
			
			if ( connectionTimer ) {
				
				connectionTimer.stop();
				connectionTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
				connectionTimer = null;
				
			}
			
			connectionTimer = new Timer( TIMEOUT * 1000, 1 );
			connectionTimer.addEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
			connectionTimer.start();
			
			processInfo.arguments = params;
			process.start( processInfo );
			if ( hasStandardInput ) startStandardInputProcessing();
			
		}
		
		private function restart():void {
			
			hasFrame = false;
			currentRetry++;
			dispatchOutput( String( args ) );
			if ( connectionTimer ) {
				
				connectionTimer.stop();
				connectionTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
				connectionTimer = null;
				
			}
			
			connectionTimer = new Timer( TIMEOUT * 1000, 1 );
			connectionTimer.addEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
			connectionTimer.start();
			
			process.start( processInfo );
			if ( hasStandardInput ) startStandardInputProcessing();
			
		}
		
		private function startStandardInputProcessing():void {
			
			silenceTimer = new Timer( 1000 );
			silenceTimer.addEventListener( TimerEvent.TIMER, writeSilence );
			silenceTimer.start();
			
		}
		
		private function writeSilence( e:TimerEvent ):void {
			
			silenceBytes.position = 0;
			process.standardInput.writeBytes( silenceBytes );
			
		}
		
		private function connectionTimerComplete( e:TimerEvent ):void {
			
			connectionTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
			var evt:FFMPEGEvent = new FFMPEGEvent( FFMPEGEvent.CONNECTION_ERROR );
			this.dispatchEvent( evt );
			stop( true );
			
		}
		
		public function stop( forced:Boolean = false ):void {
			
			if ( process && process.running ) {
				
				try {
					standardOutput.readBytes( tempBA );
					tempBA.clear();
				} catch (e:Error) {}
				
				if ( forced ) {
					process.exit( forced );
				} else {
					sendCommand( "q" );
				}
				
			}
			
		}
		
		private function addListeners():void {
			
			process.addEventListener( ProgressEvent.STANDARD_ERROR_DATA, standardErrorData );
			process.addEventListener( ProgressEvent.STANDARD_INPUT_PROGRESS, standardInputProgress );
			process.addEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, standardOutputData );
			process.addEventListener( IOErrorEvent.STANDARD_ERROR_IO_ERROR, processIOError );
			process.addEventListener( IOErrorEvent.STANDARD_INPUT_IO_ERROR, processIOError );
			process.addEventListener( IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, processIOError );
			process.addEventListener( NativeProcessExitEvent.EXIT, processExit );
			
		}
		
		private function removeListeners():void {
			
			process.removeEventListener( ProgressEvent.STANDARD_ERROR_DATA, standardErrorData );
			process.removeEventListener( ProgressEvent.STANDARD_INPUT_PROGRESS, standardInputProgress );
			process.removeEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, standardOutputData );
			process.removeEventListener( IOErrorEvent.STANDARD_ERROR_IO_ERROR, processIOError );
			process.removeEventListener( IOErrorEvent.STANDARD_INPUT_IO_ERROR, processIOError );
			process.removeEventListener( IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, processIOError );
			process.removeEventListener( NativeProcessExitEvent.EXIT, processExit );
			
		}
		
		public function sendCommand( s:String ):void {
			
			if ( process && process.running ) process.standardInput.writeUTFBytes( s );
			
		}
		
		private function dispose( ):void {
			
			FFMPEGManager.removeProcess( this );
			
			if ( silenceTimer ) {
				
				silenceTimer.stop();
				silenceTimer.removeEventListener( TimerEvent.TIMER, writeSilence );
				silenceTimer = null;
				
			}
			
			if ( connectionTimer ) {
				
				connectionTimer.stop();
				connectionTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, connectionTimerComplete );
				connectionTimer = null;
				
			}
			
			var i:int;
			
			for ( i = 0; i < outputs2.length; i++ ) {
				
				outputs2[i].dispose();
				outputs2[i] = null;
				
			}
			
			for ( i = 0; i < inputs2.length; i++ ) {
				
				inputs2[i].dispose();
				inputs2[i] = null;
				
			}
			
			outputs2 = null;
			inputs2 = null;
			
			removeListeners();
			processInfo = null;
			process = null;
			args = null;
			
		}
		
		public function addInput( i:FInput ):void {
			
			i.encoder = this;
			if ( i is IPipe ) hasStandardInput = true;
			inputs2.push( i );
			
		}
		
		public function addOutput( i:FOutput ):void {
			
			i.encoder = this;
			outputs2.push( i );
			
		}
		
		public function enableOutputPipes():void {
			
			for ( var i:int = 0; i < outputs2.length; i++ ) {
				
				if ( outputs2[i].piped ) outputs2[i].pipeEnabled = true;
				
			}
			
		}
		
		public function disableOutputPipes():void {
			
			for ( var i:int = 0; i < outputs2.length; i++ ) {
				
				if ( outputs2[i].piped ) outputs2[i].pipeEnabled = false;
				
			}
			
		}
		
		//
		// Getters and Setters
		//
		
		public function get standardError():IDataInput {
			
			return process.standardError;
			
		}
		
		private function get standardOutput():IDataInput {
			
			return process.standardOutput;
			
		}
		
		private function get standardInput():IDataOutput {
			
			return process.standardInput;
			
		}
		
		public function get numInputs():int {
			
			return inputs2.length;
			
		}
		
		public function get numOutputs():int {
			
			return outputs2.length;
			
		}
		
		public function get isInputVideoH264():Boolean {
			
			return ( inputVideoCodec.toLowerCase().search( "h264" ) >= 0 );
			
		}
		
		private function get standardOutputEnabled():Boolean {
			
			return stdOutEnabled;
			
		}
		
		private function set standardOutputEnabled( value:Boolean ):void {
			
			stdOutEnabled = value;
			
			if ( stdOutEnabled ) {
				
				//this.dispatchEvent( new FFMPEGEvent( FFMPEGEvent.STDOUT_START ) );
				
				process.addEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, standardOutputData );
				
			} else {
				
				//this.dispatchEvent( new FFMPEGEvent( FFMPEGEvent.STDOUT_STOP ) );
				
				process.removeEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, standardOutputData );
				
			}
			
		}
		
		public function addStreamClient( o:Object ):void {
			
			if ( numStreamClients == 0 ) standardOutputEnabled = true;
			numStreamClients++;
			
		}
		
		public function removeStreamClient( o:Object ):void {
			
			numStreamClients--;
			
			if ( numStreamClients <= 0 ) {
				
				numStreamClients = 0;
				standardOutputEnabled = false;
				
			}
			
		}
		
		public function clearStreamClients():void {
			
			numStreamClients = 0;
			standardOutputEnabled = false;
			
		}
		
		//
		// FFMPEG Options
		//
		
		public function get stdin():Boolean {
			
			return _stdin;
			
		}
		
		public function set stdin( value:Boolean ):void {
			
			_stdin = value;
			
		}
		
		public function get overwriteFiles():Boolean {
			
			return _overwriteFiles;
			
		}
		
		public function set overwriteFiles( value:Boolean ):void {
			
			_overwriteFiles = value;
			
		}
		
		public function get stats():Boolean {
			
			return _stats;
			
		}
		
		public function set stats( value:Boolean ):void {
			
			_stats = value;
			
		}
		
		public function get logging():Boolean {
			
			return _enableLogging;
			
		}
		
		public function set logging( value:Boolean ):void {
			
			_enableLogging = value;
			
		}
		
		public function get logLevel():String {
			
			return _logLevel;
			
		}
		
		public function set logLevel( value:String ):void {
			
			_logLevel = value;
			
		}
		
		public function get threads():int {
			
			return _threads;
			
		}
		
		public function set threads( value:int ):void {
			
			_threads = value;
			
		}
		
		public function get threadQueueSize():int {
			
			return _threadQueueSize;
			
		}
		
		public function set threadQueueSize( value:int ):void {
			
			_threadQueueSize = value;
			
		}
		
		public function get parameters():Vector.<String> {
			
			if ( processInfo ) return processInfo.arguments;
			return null;
			
		}
		
		public function get workingDirectory():File {
			
			return processInfo.workingDirectory;
			
		}
		
		public function set workingDirectory( value:File ):void {
			
			processInfo.workingDirectory = value;
			
		}
		
		public function readDataBytes( target:ByteArray ):void {
			
			_dataBytes.readBytes( target );
			_dataBytes.clear();
			
		}
		
	}

}