package live.cameleon.modules {

/**
 * 
 * Live Broadcaster
 * Live Streaming Software for Mac / Windows
 * Copyright (c) 2014 - 2017 Yatko (LLC) and Kalman Venczel
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
 * Author: Tamas Sopronyi, 2017
 * 
 */
 
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.JPEGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	
	import mx.events.FlexEvent;
	
	import live.cameleon.helpers.DeviceHelper;
	import live.cameleon.logger.LogEntry;
	import live.cameleon.logger.Logger;
	import live.cameleon.net.cameleoncenter.CameleonCenterEvent;
	import live.cameleon.system.Os;
	
	import org.igazine.apis.youtube.YouTubeHelper;
	import org.igazine.nativeprocess.encoder.FFMPEG;
	import org.igazine.nativeprocess.events.FFMPEGEvent;
	
	import live.cameleon.settings.Debug;
	import live.cameleon.settings.Encoder;
	import live.cameleon.settings.URLs;
	import live.cameleon.settings.UserSettings;
	
	public class StreamerModule extends AccountModule {
		
		protected var quality:Object;
		
		public function StreamerModule() {
			
			super();
			
		}
		
		override protected function mainWindowComplete( e:FlexEvent ):void {
			
			super.mainWindowComplete(e);
			
			streamBox.addEventListener( Event.CANCEL, refreshDevices );
			streamBox.addEventListener( Event.VIDEO_FRAME, videoFrame );
			
			youtubePanel.addEventListener( Event.INIT, youtubeInit );
			youtubePanel.addEventListener( Event.CONNECT, youtubeRecheck );
			youtubePanel.addEventListener( Event.CLOSE, youtubeFinished );
			
			facebookPanel.addEventListener( Event.INIT, facebookInit );
			facebookPanel.addEventListener( Event.CLOSE, facebookFinished );
			
		}
		
		protected function videoFrame( e:Event ):void {
			
			youtubePanel.streaming = true;
			facebookPanel.streaming = true;
			header.streaming = true;
			
		}
		
		protected function refreshDevices( e:Event = null ):void {
			
			cameraSettings = null;
			
			if ( cc && cc.connected ) {
				
				cc.addEventListener( CameleonCenterEvent.STREAMS_LOADED, ccStreamsLoaded );
				cc.addEventListener( CameleonCenterEvent.STREAMS_FAILED, ccStreamsLoaded );
				cc.getStreams();
				
			}
			
		}
		
		protected function ccStreamsLoaded( e:CameleonCenterEvent ):void {
			
			cc.removeEventListener( CameleonCenterEvent.STREAMS_LOADED, ccStreamsLoaded );
			cc.removeEventListener( CameleonCenterEvent.STREAMS_FAILED, ccStreamsLoaded );
			getDevices();
			
		}
		
		protected function youtubeRecheck( e:Event ):void {
			
			checkYouTubeLiveStreaming();
			
		}
		
		protected function resetWarnings():void {
			
			hasError = false;
			hasWarning = false; 
			
		}
		
		public function connectDevice( deviceParams:Object ):void {
			
			streamBox.connecting = true;
			videoBox.connecting = true;
			streamBox.currentState = "connecting";
			
			usedDeviceParams = deviceParams;
			
			connecting = true;
			connected = false;
			
			for ( var i:String in deviceParams ) trace( 'deviceParams', i, deviceParams[i] );
			
			// Setting fbCompatible so Facebook streaming can be disabled or enabled 
			fbCompatible = ( Boolean( deviceParams.fb ) || ( ( int( deviceParams.mode.height ) <= 720 ) && ( int( deviceParams.mode.fps ) < 60 ) ) );
			
			setupFFMPEG();
			
			var s:Vector.<String>;
			if ( deviceParams.type == DeviceHelper.DEVICE_TYPE_WEBCAM ) s = createWebcamEncoder( deviceParams );
			if ( deviceParams.type == DeviceHelper.DEVICE_TYPE_DESKTOP_CAPTURE ) s = createDesktopCaptureEncoder( deviceParams );
			
			s.push( "-c:v", Encoder.VIDEO_CODEC, "-flags", "+global_header", "-pix_fmt", "yuv420p" );
			s.push( "-profile:v", Encoder.H264_PROFILE, "-level:v", Encoder.H264_LEVEL );
			
			quality = YouTubeHelper.getQuality( YouTubeHelper.getConformedHeight( deviceParams.mode.height, Boolean( deviceParams.fb ) ), YouTubeHelper.getConformedFPS( deviceParams.mode.fps ), deviceParams.quality, Boolean( deviceParams.fb ) );
			
			s.push( "-b:v", String( quality.bv ) + "k" );
			s.push( "-bufsize", String( ( quality.bv + quality.ba ) * 2 ) + "k" );
			s.push( "-vf", "scale=-1:" + String( YouTubeHelper.getConformedHeight( deviceParams.mode.height, Boolean( deviceParams.fb ) ) ) );
			
			if ( useAudioInPreview ) s.push( "-c:a", "aac", "-ar", "44100", "-b:a", String( quality.ba ) +"k", "-bsf:a", "aac_adtstoasc" );
			//if ( useAudioInPreview ) s.push( "-c:a", "libfdk_aac", "-ar", "44100", "-b:a", String( quality.ba ) +"k", "-bsf:a", "aac_adtstoasc" );			
			//if ( useAudioInPreview ) s.push( "-c:a", "libmp3lame", "-ar", "44100", "-sample_fmt", "s16p", "-b:a", String( quality.ba ) +"k" );
			//if ( useAudioInPreview ) s.push( "-c:a", "pcm_s16be", "-ar", "44100" );
			
			s.push( "-r", String( YouTubeHelper.getConformedFPS( deviceParams.mode.fps, Boolean( deviceParams.fb ) ) ), "-g", String( YouTubeHelper.getConformedFPS( deviceParams.mode.fps, Boolean( deviceParams.fb ) ) * 2 ) );
			
			//s.push( "-force_key_frames", "2", "-copytb", "1", "-copyts", "-tune", "zerolatency" ); //copyts causes errors
			s.push( "-force_key_frames", "2", "-copytb", "1", "-tune", "zerolatency" );
			s = s.concat( getMetadata( deviceParams ) );
			
			if ( useFastestEncoding ) s.push( "-preset", "ultrafast" );
			s.push( "-f", "tee" );
			
			s = s.concat( getMapping( deviceParams ) );
			
			s.push( "[f=flv]" + cc.fullRTMPAddress + URLs.SERVER_STREAM_NAME );
			
			trace( s.join( " " ) );
			ffmpeg.execute( s );
			
			var l:LogEntry = new LogEntry();
			l.level = Logger.LEVEL_INFO;
			l.category = Logger.CATEGORY_ENCODER;
			l.text = "START";
			l.addChildObject( { text:"Video device: " + deviceParams.video } );
			l.addChildObject( { text:"Video settings: " + String( deviceParams.mode.width ) + "x" + String( deviceParams.mode.height ) + " @" + String( deviceParams.mode.fps ) } );
			l.addChildObject( { text:"Audio device: " + deviceParams.audio } );
			l.addChildObject( { text:"Streaming quality: " + String( quality.bv + quality.ba ) + "k" } );
			Logger.addEntry( l );
			
			/*
			var le:LogEntry = new LogEntry();
			le.level = Logger.LEVEL_ERROR;
			le.category = Logger.CATEGORY_ENCODER;
			le.text = "ERROR";
			Logger.addEntry( le );
			*/
			
		}
		
		protected function getMapping( deviceParams:Object ):Vector.<String> {
			
			//if ( useAudioInPreview ) s.push( "-map", "0:0", "-map", "0:1" ) else s.push( "-map", "0:0" );
			var s:Vector.<String> = new Vector.<String>();
			if ( deviceParams.type == DeviceHelper.DEVICE_TYPE_WEBCAM ) s.push( "-map", "0:0", "-map", "0:1" );
			
			if ( deviceParams.type == DeviceHelper.DEVICE_TYPE_DESKTOP_CAPTURE ) {
				
				if ( Os.isMac ) s.push( "-map", "0:0", "-map", "0:1" ) else s.push( "-map", "0:0", "-map", "1:0" );
				
			}
			
			return s;
			
		}
		
		protected function getMetadata( deviceParams:Object ):Vector.<String> {
			
			var s:Vector.<String> = new Vector.<String>();
			s.push( "-metadata", "Creator=https://cameleon.live" );
			s.push( "-metadata", "xmeta_enabled=xmeta_enabled:1" );
			s.push( "-metadata", "xmeta_width=xmeta_width:" + String( deviceParams.mode.width ) );
			s.push( "-metadata", "xmeta_height=xmeta_height:" + String( deviceParams.mode.height ) );
			s.push( "-metadata", "xmeta_fps=xmeta_fps:" + String( deviceParams.mode.fps ) );
			s.push( "-metadata", "xmeta_bv=xmeta_bv:" + String( quality.bv ) );
			s.push( "-metadata", "xmeta_ba=xmeta_ba:" + String( quality.ba ) );
			s.push( "-metadata", "xmeta_orientation=xmeta_orientation:landscape" );
			return s;
			
		}
		
		protected function createWebcamEncoder( deviceParams:Object ):Vector.<String> {
			
			var s:Vector.<String> = new Vector.<String>();
			
			s.push( "-stats", "-y", "-loglevel", "32" );
			if ( Encoder.LOGGING ) s.push( "-report" );
			//s.push( "-thread_queue_size", "512" );
			//s.push( "-probesize", "10000k" );
			if ( Os.isMac ) s.push( "-f", "avfoundation" ) else s.push( "-f", "dshow" );
			s.push( "-vcodec", String( deviceParams.mode.vcodec ) );
			s.push( "-s", String( deviceParams.mode.width ) + "x" + String( deviceParams.mode.height ) );
			s.push( "-framerate", String( Number( deviceParams.mode.fps ) ) );
			
			if ( Os.isMac ) {
				
				if ( useAudioInPreview ) {
					
					s.push( '-i', String( deviceParams.video ) + ':' + String( deviceParams.audio ) );
					
				} else {
				
					s.push( '-i', String( deviceParams.video ) );
					
				}
				
			} else {
				
				//s.push( "-rtbufsize 50000k" );
				
				if ( useAudioInPreview ) {
				
					s.push( '-i', 'video=' + String( deviceParams.video ) + ':audio=' + String( deviceParams.audio ) );
					
				} else {
				
					s.push( '-i', 'video=' + String( deviceParams.video ));
					
				}
				
			}
			
			return s;
			
		}
		
		protected function createDesktopCaptureEncoder( deviceParams:Object ):Vector.<String> {
			
			// mac
			//ffmpeg -y -f avfoundation -framerate 10 -video_size 640x360 -capture_cursor 1 -capture_mouse_clicks 1 -i "3:none" -c:v libx264 -r 10 desktop.mp4
			
			// win
			// ffmpeg -y -f gdigrab -framerate 6 -i desktop xxx.mp4
			// ffmpeg -y -f gdigrab -video_size 640x360 -offset_x 10 -offset_y 20 -framerate 10 -i desktop xxx.mp4
			// ffmpeg -y -f gdigrab -draw_mouse 0 -framerate 25 -i desktop xxx.mp4
			
			var s:Vector.<String> = new Vector.<String>();
			s.push( "-stats", "-y", "-loglevel", "32" );
			if ( Encoder.LOGGING ) s.push( "-report" );
			//s.push( "-thread_queue_size", "512" );
			
			if ( Os.isMac ) {
				
				s.push( "-f", "avfoundation" )
				s.push( "-capture_cursor", int( deviceParams.mouse ) );
				s.push( "-capture_mouse_clicks", int( deviceParams.mouseclick ) );
				
			} else {
				
				s.push( "-f", "gdigrab" );
				s.push( "-draw_mouse", int( deviceParams.mouse ) );
				
			}
			
			s.push( "-s", String( deviceParams.mode.width ) + "x" + String( deviceParams.mode.height ) );
			s.push( "-framerate", String( Number( deviceParams.mode.fps ) ) );
			
			if ( !Os.isMac ) s.push( "-i", "desktop" );
			
			if ( Os.isMac ) {
				
				s.push( '-i', 'Capture screen:' + String( deviceParams.audio ) );
				
			} else {
				
				//s.push( "-rtbufsize 50000k" );
				
				s.push( '-f', 'dshow', '-i', 'audio=' + String( deviceParams.audio ) );
				
			}
			
			return s;
			
		}
		
		public function disconnectDevice():void {
			
			ffmpegManualStop = true;
			connecting = false;
			connected = false;
			fbCompatible = true;
			
			//removeFFMPEGListeners();
			
			if ( ffmpeg ) {
				
				ffmpeg.stop();
				
			}
			
			processing = true;
			youtubePanel.streaming = false;
			facebookPanel.streaming = false;
			header.hasConnection = false;
			header.streaming = false;
			
		}
		
		protected function setupFFMPEG():void {
			
			if ( !ffmpeg ) {
				
				ffmpeg = new FFMPEG( ffmpegFile );
				
			}
			
			ffmpeg.workingDirectory = File.applicationStorageDirectory;
			ffmpegWorkingDirectory = File.applicationStorageDirectory;
			ffmpegWorkingDirectory.createDirectory();
			ffmpeg.overwriteFiles = true;
			//ffmpeg.logging = config.logging;
			
			createFFMPEGListeners();
			
		}
		
		private function getActiveCameraPixelFormat( theName:String, isMac:Boolean = false ):String {
			
			if ( theName.toLowerCase().search( "manycam" ) >= 0 ) {
				
				if ( isMac ) return "yuyv422" else return "bgr24";
				
			}
			
			return undefined;
			
		}
		
		protected function createFFMPEGListeners():void {
			
			if ( ffmpeg ) {
				
				ffmpeg.addEventListener( FFMPEGEvent.INIT, ffmpegInit );
				ffmpeg.addEventListener( FFMPEGEvent.RETRY, ffmpegRetry );
				ffmpeg.addEventListener( FFMPEGEvent.START, ffmpegStart );
				ffmpeg.addEventListener( FFMPEGEvent.EXIT, ffmpegExit );
				ffmpeg.addEventListener( FFMPEGEvent.CONNECTION_ERROR, ffmpegConnectionError );
				ffmpeg.addEventListener( FFMPEGEvent.VIDEO_STREAM_FOUND, ffmpegVideoStreamFound );
				ffmpeg.addEventListener( FFMPEGEvent.ERROR_OUTPUT, ffmpegOutput );
				
			}
			
		}
		
		protected function removeFFMPEGListeners():void {
			
			if ( ffmpeg ) {
				
				ffmpeg.removeEventListener( FFMPEGEvent.INIT, ffmpegInit );
				ffmpeg.removeEventListener( FFMPEGEvent.RETRY, ffmpegRetry );
				ffmpeg.removeEventListener( FFMPEGEvent.START, ffmpegStart );
				ffmpeg.removeEventListener( FFMPEGEvent.EXIT, ffmpegExit );
				ffmpeg.removeEventListener( FFMPEGEvent.CONNECTION_ERROR, ffmpegConnectionError );
				ffmpeg.removeEventListener( FFMPEGEvent.VIDEO_STREAM_FOUND, ffmpegVideoStreamFound );
				ffmpeg.removeEventListener( FFMPEGEvent.ERROR_OUTPUT, ffmpegOutput );
				
			}
			
		}
		
		protected function ffmpegInit ( e:FFMPEGEvent ):void {
			
			trace( 'ffmpegInit' );
			
		}
		
		protected function ffmpegRetry ( e:FFMPEGEvent ):void {
			
			trace( 'ffmpegRetry' );
			
		}
		
		protected function ffmpegStart ( e:FFMPEGEvent ):void {
			
			// FFMPEG Started streaming successfully
			trace( 'ffmpegStart' );
			UserSettings.cameraSettings = usedDeviceParams;
			
			var streamAddress:String = cc.rtmpProtocol + "://" + cc.address + ":" + cc.rtmpPort + "/" + cc.applicationName + "/";
			
			trace( "Connecting to: ", streamAddress + URLs.SERVER_STREAM_NAME );
			
			streamBox.connectStream( streamAddress, URLs.SERVER_STREAM_NAME );
			
			streamBox.videoWidth = usedDeviceParams.mode.width;
			streamBox.videoHeight = usedDeviceParams.mode.height;
			
			streamBox.currentState = "stop";
			onResize(); 
			
		}
		
		protected function ffmpegExit ( e:FFMPEGEvent ):void {
			
			trace( 'ffmpegExit' );
			connecting = false;
			connected = false;
			fbCompatible = true;
			removeFFMPEGListeners();
			ffmpeg = null;
			
			if ( !ffmpegManualStop ) {
				
				var le:LogEntry = new LogEntry();
				le.level = Logger.LEVEL_ERROR;
				le.category = Logger.CATEGORY_ENCODER;
				le.text = "Encoder has exited abnormally. Please check if the device is connected or the defined address is accessible";
				Logger.addEntry( le );
				
			}
			
			streamBox.currentState = "connect";
			streamBox.disconnectStream();
			streamBox.connected = false;
			streamBox.connecting = false;
			videoBox.connected = false;
			videoBox.connecting = false;
			processing = false;
			
		}
		
		protected function ffmpegConnectionError ( e:FFMPEGEvent ):void {
			
			trace( 'ffmpegConnectionError' );
			connecting = false;
			connected = false;
			fbCompatible = true;
			removeFFMPEGListeners();
			ffmpeg = null;
			
			var le:LogEntry = new LogEntry();
			le.level = Logger.LEVEL_ERROR;
			le.category = Logger.CATEGORY_ENCODER;
			le.text = "Cannot access selected device. Please check if the device is connected or the defined address is accessible";
			Logger.addEntry( le );
			
			streamBox.currentState = "connect";
			streamBox.disconnectStream();
			streamBox.connected = false;
			streamBox.connecting = false;
			videoBox.connected = false;
			videoBox.connecting = false;
			processing = false;
			youtubePanel.streaming = false;
			facebookPanel.streaming = false;
			
		}
		
		protected function ffmpegVideoStreamFound ( e:FFMPEGEvent ):void {
			
			trace( 'ffmpegVideoStreamFound' );
			streamBox.connected = true;
			videoBox.connected = true;
			
		}
		
		protected function ffmpegOutput ( e:FFMPEGEvent ):void {
			
			if ( Debug.TRACE_FFMPEG ) trace( e.data );
			
		}
		
		protected function getRTMPAddress( isHQ:Boolean = false ):String {
			
			if ( isHQ ) return cc.rtmpProtocol + "://" + cc.address + ":" + cc.rtmpPort + "/" + cc.applicationName + "/" + URLs.SERVER_STREAM_NAME + "_hq";
			
			return cc.rtmpProtocol + "://" + cc.address + ":" + cc.rtmpPort + "/" + cc.applicationName + "/" + URLs.SERVER_STREAM_NAME;
			
		}
		
		public function onMetaData( w:int, h:int, fps:int, vbw:Number, abw:Number ):void {
			
			videoWidth = w;
			videoHeight = h;
			videoFPS = fps;
			videoBW = vbw;
			audioBW = abw;
			
			pipWindow.videoWidth = w;
			pipWindow.videoHeight = h;
			pipWindow.onResize();
			
		}
		
		protected function onResize():void {
			
			//if ( streamBox ) streamBox.onResize();
			
		}
		
		public function streamPlaying( ns:NetStream ):void {
			
			//pipWindow.attachNetStream( ns );
			
		}

		override public function exitAppManual():void {
			
			super.exitAppManual();
			
			if ( ffmpeg ) {
				
				ffmpeg.disableRetry = true;
				ffmpeg.stop();
				
			}
			
		}
		
		public function setYoutubeStream( streaming:Boolean ):void {
			
			header.hasConnection = streaming;
			
		}
		
		public function setFacebookStream( facebookStreaming:Boolean, ffmpegStreaming:Boolean ):void {
			
			header.hasConnection = facebookStreaming && ffmpegStreaming;
			
		}
		
		protected function createStreamBitmap( e:Event ):void {
			
			var bmp:BitmapData = mainWindow.getStreamBitmapData();
			bmp.applyFilter( bmp, bmp.rect, new Point( 0, 0 ), new BlurFilter( 50, 50 ) );
			var rLum : Number = 0.2225;
			var gLum : Number = 0.7169;
			var bLum : Number = 0.0606; 
			var matrix:Array = [ rLum, gLum, bLum, 0, 0, rLum, gLum, bLum, 0, 0, rLum, gLum, bLum, 0, 0, 0,    0,    0,    1, 0 ];
			bmp.applyFilter( bmp, bmp.rect, new Point( 0, 0 ), new ColorMatrixFilter( matrix ) );
			
			var bmpNoise:BitmapData = new BitmapData( bmp.width, bmp.height, true, 0 );
			bmpNoise.noise( Math.random() * int.MAX_VALUE, 0, 80, 7, true );
			bmp.draw( bmpNoise, null, null, BlendMode.ADD );
			
			var ba:ByteArray = new ByteArray();
			bmp.encode( bmp.rect, new JPEGEncoderOptions(), ba );
			
			var bf:File = File.applicationStorageDirectory.resolvePath( String( usedDeviceParams.video ) + ".jpg" );
			var bfs:FileStream = new FileStream();
			
			try {
				
				bfs.open( bf, FileMode.WRITE );
				bfs.writeBytes( ba );
				bfs.close();
				
			} catch ( e:Error ) {}
			
			loadSnapshot();
			
		}
		
	}

}