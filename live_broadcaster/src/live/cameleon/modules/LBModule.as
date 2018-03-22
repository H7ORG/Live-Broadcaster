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
 
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenuItem;
	import flash.display.Screen;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import live.cameleon.assets.Embed;
	import live.cameleon.helpers.DeviceHelper;
	import live.cameleon.licenser.Licenser;
	import live.cameleon.logger.LogEntry;
	import live.cameleon.logger.Logger;
	import live.cameleon.net.cameleoncenter.CameleonCenterClient;
	import live.cameleon.net.cameleoncenter.CameleonCenterEvent;
	import live.cameleon.net.cameleoncenter.CameleonCenterHelper;
	import live.cameleon.settings.Application;
	import live.cameleon.settings.Constants;
	import live.cameleon.settings.ServerSettings;
	import live.cameleon.settings.URLs;
	import live.cameleon.settings.UserSettings;
	import live.cameleon.views.CCWindow;
	import live.cameleon.views.FacebookPanel;
	import live.cameleon.views.Header;
	import live.cameleon.views.LogWindow;
	import live.cameleon.views.PIPWindow;
	import live.cameleon.views.StreamBox;
	import live.cameleon.views.VideoBox;
	import live.cameleon.views.YouTubePanel;
	
	import org.igazine.nativeprocess.encoder.FFMPEG;
	import org.igazine.nativeprocess.encoder.info.DeviceInfoQuery;
	import org.igazine.nativeprocess.encoder.info.DeviceList;
	
	import settings.API;
	
	public class LBModule extends ModuleBase implements IModuleInterface {
		
		public var mainWindow:MainWindow;
		protected var pipWindow:PIPWindow;
		protected var ccWindow:CCWindow;
		protected var streamBox:StreamBox;
		protected var videoBox:VideoBox;
		public var facebookPanel:FacebookPanel;
		protected var youtubePanel:YouTubePanel;
		protected var header:Header;
		
		protected var appXML:XML;
		protected var appNS:Namespace;
		
		[Bindable] public var hasError:Boolean;
		[Bindable] public var hasWarning:Boolean;
 		
		
		private var _processing:Boolean;

		[Bindable]
		public function get processing():Boolean
		{
			return _processing;
		}

		public function set processing(value:Boolean):void
		{
			_processing = value;
		}

		
		[Bindable] public var zoom:Boolean;
		
		public var cc:CameleonCenterClient;
		protected var lbLua:ByteArray = new Embed.LiveBroadcasterLuaClass() as ByteArray;
		protected var lbLog:ByteArray = new Embed.LiveBroadcasterLogClass() as ByteArray;
		
		protected var cameraSources:Array;
		protected var microphoneSources:Array;
		protected var ffmpeg:FFMPEG;
		protected var deviceList:DeviceList;
		protected var deviceQuery:DeviceInfoQuery;
		protected var ffmpegWorkingDirectory:File;
		protected var usedDeviceParams:Object;
		protected var desktopModes:XML;
		protected var ffmpegManualStop:Boolean;
		public var ffmpegFile:File;
		protected var logWindow:LogWindow;
		public var logHTMLFile:File;
		
		[Bindable] public var fbCompatible:Boolean = true;
		[Bindable] public var connecting:Boolean;
		[Bindable] public var connected:Boolean;
		[Bindable] public var videoWidth:int;
		[Bindable] public var videoHeight:int;
		[Bindable] public var outputWidth:int;
		[Bindable] public var outputHeight:int;
		[Bindable] public var videoFPS:int;
		[Bindable] public var videoBW:Number;
		[Bindable] public var audioBW:Number;
		[Bindable] public var useFastestEncoding:Boolean = true;
		[Bindable] public var useAudioInPreview:Boolean = true;
		
		protected var cameraDevices:ArrayCollection = new ArrayCollection();
		protected var audioDevices:ArrayCollection = new ArrayCollection();
		protected var selectedAudioDevice:Object;
		protected var selectedVideoDevice:Object;
		
		protected var loggerInitialised:Boolean;
		
		public var coreVersionText:String;
		
		public function LBModule() {
			
			super();
			
			appXML = NativeApplication.nativeApplication.applicationDescriptor;
			appNS = appXML.namespace();
			
			UserSettings.facebookAppId = API.I.FACEBOOK_APP_ID;
			UserSettings.load();
			
		}
		
		override protected function init():void {
			
			super.init();
			
			trace( getModuleName(), "init", getModuleVersion(), this.parentApplication );
			
			if ( CameleonCenterHelper.storagePath.exists ) initLogger();
			
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, mainWindowComplete );
			mainWindow.open();
			
			pipWindow = new PIPWindow();
			pipWindow.pipFunction = this.pip;
			pipWindow.visible = false;
			pipWindow.open();
			
			this.loaderInfo.uncaughtErrorEvents.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError );
			
			this.addEventListener( Event.CLOSING, appExiting );
			NativeApplication.nativeApplication.addEventListener( Event.EXITING, appExiting );
			if ( UserSettings.windowBounds ) mainWindow.nativeWindow.bounds = UserSettings.windowBounds;
			//if ( UserSettings.windowMaximized ) { this.maximizeApp() }
			if ( UserSettings.pipWindowBounds ) pipWindow.nativeWindow.bounds = UserSettings.pipWindowBounds;
			zoom = UserSettings.zoom;
			
			/*
			trace( this.parentApplication.menu, this.nativeApplication.menu, this.nativeWindow, this.nativeWindow.menu );
			if ( this.nativeApplication.menu ) this.nativeApplication.menu.addEventListener( Event.SELECT, menuItemSelected );
			if ( NativeApplication.supportsDockIcon ) {
				var di:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				trace( di, di.menu );
				if ( di.menu ) di.menu.addEventListener( Event.SELECT, dockIconMenuItemSelected );
			}
			
			this.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, windowStateChanging );
			*/
			
			ccWindow = new CCWindow();
			
			cc = new CameleonCenterClient();
			addCCListeners();
			initializeCCConnection();
			
		}
		
		protected function mainWindowComplete( e:FlexEvent ):void {
			
			mainWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, mainWindowComplete );
			streamBox = mainWindow.streamBox;
			videoBox = mainWindow.streamBox.videoBox;
			youtubePanel = mainWindow.youtubePanel;
			facebookPanel = mainWindow.facebookPanel;
			facebookPanel.fbIncompatible = !fbCompatible;
			header = mainWindow.header;
			
		}
		
		protected function appExiting( e:Event ):void {
			
			trace( "DesktopApp.appExiting" );
			e.preventDefault();
			processing = true;
			exitAppManual();
			
		}
		
		public function exitAppManual():void {
			
			trace( "DesktopApp.exitAppManual" );
			processing = true;
			
			// Stopping MonaServer application by overwriting LUA file
			
			if ( CameleonCenterHelper.storagePath && CameleonCenterHelper.storagePath.exists ) {
				
				var lf:File = CameleonCenterHelper.dataPath.resolvePath( "LiveBroadcaster/main.lua" );
				var lfs:FileStream = new FileStream();
				
				try {
					
					lfs.open( lf, FileMode.WRITE );
					lfs.writeBytes( lbLua );
					lfs.close();
					
				} catch ( e:Error ) {}
				
			}
			
			if ( !mainWindow.maximized ) UserSettings.windowBounds = mainWindow.nativeWindow.bounds;
			UserSettings.pipWindowBounds = pipWindow.nativeWindow.bounds;
			//UserSettings.windowMaximized = this.maximized;
			UserSettings.save();
			setupExitTimer();
			//this.exit();
			
		}
		
		protected function setupExitTimer():void {
			
			var exitTimer:Timer = new Timer( 1000 );
			exitTimer.addEventListener( TimerEvent.TIMER, exitTimerEvent );
			exitTimer.start();
			
		}
		
		protected function exitTimerEvent( e:TimerEvent ):void {
			
			continueExit();
			
		}
		
		protected function continueExit():void {
			
			this.parentApplication.exit();
			
		}
		
		public function exit():void {
			
			
			
		}
		
		protected function menuItemSelected( e:Event ):void {
			
			var nmi:NativeMenuItem = e.target as NativeMenuItem;
			trace( 'LBModule.menuItemSelected', nmi.keyEquivalent, nmi.label, nmi.name );
			if ( nmi.keyEquivalent == "q" ) exitAppManual();
			
		}
		
		protected function dockIconMenuItemSelected( e:Event ):void {
			
			var nmi:NativeMenuItem = e.target as NativeMenuItem;
			trace( 'DesktopApp.dockIconMenuItemSelected', nmi.keyEquivalent, nmi.label, nmi.name );
			//if ( nmi.keyEquivalent == "q" ) exitAppManual();
			
		}
		
		protected function windowStateChanging( e:NativeWindowDisplayStateEvent ):void {
			
			trace( "DesktopApp.windowStateChanging", e.beforeDisplayState, e.afterDisplayState );
			
		}
		
		override public function uncaughtError( e:UncaughtErrorEvent ):void {
			
			e.preventDefault();
			
			var l:LogEntry = new LogEntry();
			l.level = Logger.LEVEL_ERROR;
			l.category = Logger.CATEGORY_CORE;
			l.text = "UNCAUGHT ERROR";
			
			if ( e.error is Error ) {
				
				var err:Error = e.error as Error;
				l.addChildObject( { text:"Type: Error" } );
				l.addChildObject( { text:"ErrorID: " +  e.errorID } );
				l.addChildObject( { text:"Stack trace: " +  err.getStackTrace() } );
				
			} else if ( e.error is ErrorEvent ) {
				
				var errEvent:ErrorEvent;
				l.addChildObject( { text:"Type: ErrorEvent" } );
				l.addChildObject( { text:"ErrorID: " +  e.errorID } );
				l.addChildObject( { text:"Text: " +  errEvent.text } );
				
			} else {
				
				l.addChildObject( { text:"Type: Misc" } );
				l.addChildObject( { text:"Error: " + e.error } );
				l.addChildObject( { text:"ErrorID: " + e.errorID } );
				l.addChildObject( { text:"Text: " + e.text } );
				
			}
			
			Logger.addEntry( l );
			
			/*
			var gaError:GAEvent = new GAEvent( GAEvent.ERROR );
			gaError.description = e.error + " (" + e.errorID + ")";
			this.dispatchEvent( gaError );
			*/
			
		}
		
		//
		// Window Functions
		//
		
		public function minimizeApp():void {
			
			mainWindow.minimizeApp();
			
		}
		
		public function maximizeApp( altKey:Boolean = false ):void {
			
			mainWindow.maximizeApp( altKey );
			
		}
		
		public function showSettings():void {
			
			mainWindow.settingsWindow.setData( UserSettings.enableLogout, UserSettings.licenseEmail, UserSettings.licenseKey );
			mainWindow.showSettings();
			
		}
		
		public function showHelp():void {
			
			mainWindow.showHelp();
			
		}
		
		public function showLog():void {
			
			if ( !logWindow.created ) {
				
				logWindow.open();
				
			} else {
				
				if ( !logWindow.visible ) {
					
					logWindow.visible = true;
					
				}
				
				logWindow.orderToFront();
				
			}
			
			logWindow.activate();
			logWindow.refresh();
			
		}
		
		//
		// PIP functions
		//
		
		public function pip( open:Boolean ):void {
			
			if ( !Licenser.instance.isPro ) {
				
				mainWindow.showPro();
				return;
				
			}
			
			if ( !open ) {
				
				mainWindow.visible = true;
				mainWindow.orderToFront();
				pipWindow.visible = false;
				streamBox.videoBox.reattachNetStream();
				
			} else {
				
				mainWindow.visible = false;
				pipWindow.visible = true;
				pipWindow.nativeWindow.orderToFront();
				pipWindow.attachNetStream( streamBox.videoBox.ns );
				
			}
			
		}
		
		public function setPIPMessages( messages:Array ):void {
			
			if ( pipWindow.visible ) pipWindow.setMessages( messages );
			
		}
		
		public function updatePIP( likeCountString:String, concurrentViewersString:String, secondsLeftString:String, duration:String ):void {
			
			pipWindow.likeCountString = likeCountString;
			pipWindow.concurrentViewersString = concurrentViewersString;
			pipWindow.secondsLeftString = secondsLeftString;
			pipWindow.duration = duration;
			
		}
		
		public function updatePIPLinks( weblink:String ):void {
			
			pipWindow.weblink = weblink;
			
		}
		
		//
		// Logging
		//
		
		protected function initLogger():void {
			
			// Deleting previous FFMPEG log files
			var ffmpegLogFiles:Array = File.applicationStorageDirectory.getDirectoryListing();
			var ffmpegLogFile:File;
			
			for ( var i:int = 0; i < ffmpegLogFiles.length; i++ ) {
				
				ffmpegLogFile = ffmpegLogFiles[i] as File;
				if ( ffmpegLogFile.extension == "log" ) {
					
					try {
						
						ffmpegLogFile.deleteFile();
						
					} catch( e:Error ) {}
					
				}
				
			}
			
			var sourceDir:File = File.applicationDirectory.resolvePath( "www" );
			
			var logDir:File = CameleonCenterHelper.storagePath.resolvePath( "www/logger/logs" );
			logDir.createDirectory();
			
			logHTMLFile = CameleonCenterHelper.storagePath.resolvePath( "www/logger/" ).resolvePath( "LiveBroadcasterLog.html" );
			var lfs:FileStream = new FileStream();
			
			try {
				
				lfs.open( logHTMLFile, FileMode.WRITE );
				lfs.writeBytes( lbLog );
				lfs.close();
				
			} catch ( e:Error ) {}
			
			Logger.logFileJSON = logDir.resolvePath( Application.LOG_FILE_NAME_JSON );
			Logger.logFilePlainText = logDir.resolvePath( Application.LOG_FILE_NAME_TXT );
			Logger.init( sourceDir, logDir );
			Logger.addCallback( log );
			
			loggerInitialised = true;
			
		}
		
		protected function log( s:String, level:int ):void {
			
			if ( level >= Logger.LEVEL_ERROR ) {
				
				hasError = true;
				
			} else if ( level == Logger.LEVEL_WARNING ) {
				
				hasWarning = true;
				
			}
			
		}
		
		//
		// Cameleon Center logic
		//
		
		protected function initializeCCConnection():void {
			
			trace( "::::::::::", CameleonCenterHelper.storagePath.nativePath, CameleonCenterHelper.storagePath.exists );
			trace( "::::::::::", CameleonCenterHelper.installPath.nativePath, CameleonCenterHelper.installPath.exists );
			trace( "::::::::::", CameleonCenterHelper.executable.nativePath, CameleonCenterHelper.executable.exists );
			
			processing = true;
			
			if ( !CameleonCenterHelper.installPath || !CameleonCenterHelper.installPath.exists ) {
				
				trace( "LBModule.initializeCCConnection.installPath does not exist" );
				ccWindow.currentState = "ccnotfound";
				ccWindow.show( mainWindow, false );
				return;
				
			}
			
			cc.applicationName = "LiveBroadcaster";
			cc.address = "localhost";
			cc.clientType = "LiveBroadcaster";
			
			if ( CameleonCenterHelper.storagePath && CameleonCenterHelper.storagePath.exists ) {
				
				var lf:File = CameleonCenterHelper.dataPath.resolvePath( "LiveBroadcaster/main.lua" );
				var lfs:FileStream = new FileStream();
				
				try {
					
					lfs.open( lf, FileMode.WRITE );
					lfs.writeBytes( lbLua );
					lfs.close();
					
				} catch ( e:Error ) {}
				
			}
			
			if ( CameleonCenterHelper.installPath && CameleonCenterHelper.installPath.exists && CameleonCenterHelper.executable && CameleonCenterHelper.executable.exists ) {
				
				if ( CameleonCenterHelper.settings ) {
					
					cc.rtmpPort = CameleonCenterHelper.settings.rtmpPort;
					
				} else {
					
					cc.rtmpPort = ServerSettings.DEFAULT_RTMP_PORT;
					
				}
				
				cc.connect( { } );
				return;
				
			}
			
		}
		
		protected function addCCListeners():void {
			
			cc.addEventListener( CameleonCenterEvent.CONNECTED, ccConnected );
			cc.addEventListener( CameleonCenterEvent.CONNECTION_CLOSED, ccClosed );
			cc.addEventListener( CameleonCenterEvent.CONNECTION_FAILED, ccFailed );
			
		}
		
		protected function removeCCListeners():void {
			
			cc.addEventListener( CameleonCenterEvent.CONNECTED, ccConnected );
			cc.addEventListener( CameleonCenterEvent.CONNECTION_CLOSED, ccClosed );
			cc.addEventListener( CameleonCenterEvent.CONNECTION_FAILED, ccFailed );
			
		}
		
		protected function ccConnected( e:CameleonCenterEvent ):void {
			
			trace( "LBModule.ccConnected" );
			if ( !loggerInitialised ) initLogger();
			for ( var i:String in cc.config ) trace( "cc.config", i, cc.config[i] );
			copyFFMPEG();
			processing = false;
			mainWindow.serverState = "running";
			//setupViews();
			mainWindow.canStart = true;
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_SERVER;
			le.level = Logger.LEVEL_INFO;
			le.text = "CONNECT";
			le.addChildObject( { text:"Address: " + String( cc.address ) + ", RTMP Port: " + String( cc.rtmpPort ) + ", HTTP Port: " + String( cc.httpPort ) } );
			Logger.addEntry( le );
			
			getDevices();
			
		}
		
		protected function ccClosed( e:CameleonCenterEvent ):void {
			
			trace( "LBModule.ccClosed" );
			mainWindow.canStart = false;
			processing = false;
			mainWindow.serverState = "offline";
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_SERVER;
			le.level = Logger.LEVEL_DEBUG;
			le.text = "CONNECT CLOSED";
			le.addChildObject( { text:"Address: " + String( cc.address ) + ", RTMP Port: " + String( cc.rtmpPort ) + ", HTTP Port: " + String( cc.httpPort ) } );
			Logger.addEntry( le );
			
			//setTimeout(initializeCCConnection, 10000);
			
		}
		
		protected function ccFailed( e:CameleonCenterEvent ):void {
			
			trace( "LBModule.ccFailed" );
			processing = false;
			mainWindow.canStart = false;
			mainWindow.serverState = "offline";
			ccWindow.currentState = "ccnotrunning";
			ccWindow.show( mainWindow, false );
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_SERVER;
			le.level = Logger.LEVEL_DEBUG;
			le.text = "CONNECT FAILED";
			le.addChildObject( { text:"Address: " + String( cc.address ) + ", RTMP Port: " + String( cc.rtmpPort ) + ", HTTP Port: " + String( cc.httpPort ) } );
			Logger.addEntry( le );
			
		}
		
		public function startCameleonCenter():void {
			
			CameleonCenterHelper.executable.openWithDefaultApplication();
			
		}
		
		public function retryConnection():void {
			
			initializeCCConnection();
			
		}
		
		protected function copyFFMPEG():void {
			
			// Creating local copies of FFMPEG executables
			
			if ( !ffmpegFile ) {
			
				var inFile:File = new File( cc.config["FFMPEG.ffmpeg"] );
				
				try {
					
					inFile.copyTo( File.applicationStorageDirectory.resolvePath( Application.APP_SHORT_NAME + "." + inFile.name ), true );
					
				} catch ( e:Error ) {}
				
				ffmpegFile = File.applicationStorageDirectory.resolvePath( Application.APP_SHORT_NAME + "." + inFile.name );
				
				if ( !ffmpegFile.exists ) ffmpegFile = inFile;
				
			}
			
		}
		
		//
		// Setting up views
		//
		
		protected function setupViews():void {
			
			
		}
		
		//
		// Devices
		//
		
		protected function getDevices():void {
			
			deviceList = new DeviceList( ffmpegFile );
			deviceList.addEventListener( Event.COMPLETE, deviceListComplete );
			deviceList.run();
			
		}
		
		protected function deviceListComplete( e:Event ):void {
			
			deviceList.removeEventListener( Event.COMPLETE, deviceListComplete );
			
			cameras = deviceList.video;
			microphones = deviceList.audio;
			
			trace( deviceList.xml );
			
			var le:LogEntry = new LogEntry();
			le.category = Logger.CATEGORY_DEVICE;
			le.level = Logger.LEVEL_INFO;
			le.text = "LIST";
			var i:int;
			
			for ( i = 0; i < deviceList.xml.video.length(); i++ ) {
				
				le.addChildObject( { text:"Video: " + String( deviceList.xml.video[i] ) } );
				
			}
			
			for ( i = 0; i < deviceList.xml.audio.length(); i++ ) {
				
				le.addChildObject( { text:"Audio: " + String( deviceList.xml.audio[i] ) } );
				
			}
			
			Logger.addEntry( le );
			
			DeviceHelper.webcams = deviceList.video;
			DeviceHelper.microphones = deviceList.audio;
			if ( cc && cc.connected ) DeviceHelper.streams = cc.streams;
			//trace( DeviceHelper.getVideoDevicesXML() );
			streamBox.setVideoDevices( DeviceHelper.getVideoDevicesXML().item );
			
		}
		
		protected function set cameras( value:Array ):void {
			
			cameraSources = value;
			
			var a:Array = new Array();
			
			for ( var i:int = 0; i < cameraSources.length; i++ ) {
				
				a.push( { label:cameraSources[i], type:Constants.VIDEO_TYPE_WEBCAM } );
				
			}
			
			DeviceHelper.webcams = a;
			cameraDevices.source = a;
			
			//streamBox.videoSelector.setSelectedIndex( 0, true );
			
		}
		
		protected function set microphones( value:Array ):void {
			
			microphoneSources = value;
			
			var __microphonesX:Array = new Array();
			
			//__microphonesX.push( { label:"No audio", dummy:true, localAudio:true } );
			
			for ( var i:int = 0; i < microphoneSources.length; i++ ) {
				
				__microphonesX.push( { label:microphoneSources[i], localAudio:true, type:Constants.AUDIO_TYPE_MICROPHONE } );
				
			}
			
			audioDevices.source = __microphonesX;
			
		}
		
		public function videoDeviceChanged( item:XML ):void {
			
			trace( item.toXMLString() );
			selectedVideoDevice = item.@label;
			devicesChanged();
			
			if ( int( item.@type ) == DeviceHelper.DEVICE_TYPE_DESKTOP_CAPTURE ) {
				
				getDesktopParameters();
				
			}
				
			if ( int( item.@type ) == DeviceHelper.DEVICE_TYPE_WEBCAM ) {
				
				getVideoDeviceFormats();
				
			}
			
			if ( int( item.@type ) == DeviceHelper.DEVICE_TYPE_INCOMING ) {
				
				getIncomingStreamFormats( item );
				
			}
			
			streamBox.setAudioDevices( DeviceHelper.getAudioDevicesXML( item ).item );
			loadSnapshot();
			
		}
		
		protected function getIncomingStreamFormats( item:XML ):void {
			
			var incomingStreamFormats:XML = new XML( "<modes />" );
			
			var mode1:XML = new XML( "<mode />" );
			mode1.width = item.@width;
			mode1.height = item.@height;
			mode1.fps = item.@fps;
			mode1.label = String( item.@width ) + "x" + String( item.@height ) + " " + String( item.@fps ) +" FPS";
			mode1.youtube = 1;
			mode1.facebook = int( item.@height <= 720 );
			incomingStreamFormats.appendChild( mode1 );
			
			streamBox.setVideoModes( incomingStreamFormats.mode );
			
		}
		
		protected function loadSnapshot():void {
			
			var snapshotFile:File = File.applicationStorageDirectory.resolvePath( selectedVideoDevice + ".jpg" );
			mainWindow.streamBox.videoBox.loadSnapshot( snapshotFile );
			
		}
		
		public function audioDeviceChanged( item:XML ):void {
			
			selectedAudioDevice = item.@label;
			devicesChanged();
			
		}
		
		protected function devicesChanged():void {
			
			if ( selectedAudioDevice && selectedVideoDevice ) {
				
				//trace( 'baaaaaaaaaaaaaaaaaaaaang' );
				
			}
			
		}
		
		protected function getDesktopParameters():void {
			
			var r:Rectangle = Screen.mainScreen.bounds;
			
			desktopModes = new XML( "<modes />" );
			
			var mode1:XML = new XML( "<mode />" );
			mode1.width = r.width;
			mode1.height = r.height;
			mode1.fps = 10;
			mode1.label = String( r.width ) + "x" + String( r.height ) + " 10 FPS";
			mode1.youtube = 1;
			mode1.facebook = int( r.height <= 720 );
			desktopModes.appendChild( mode1 );
			
			var mode2:XML = new XML( "<mode />" );
			mode2.width = r.width;
			mode2.height = r.height;
			mode2.fps = 20;
			mode2.label = String( r.width ) + "x" + String( r.height ) + " 20 FPS";
			mode2.youtube = 1;
			mode2.facebook = int( r.height <= 720 );
			desktopModes.appendChild( mode2 );
			
			var mode3:XML = new XML( "<mode />" );
			mode3.width = r.width;
			mode3.height = r.height;
			mode3.fps = 30;
			mode3.label = String( r.width ) + "x" + String( r.height ) + " 30 FPS";
			mode3.youtube = 1;
			mode3.facebook = int( r.height <= 720 );
			desktopModes.appendChild( mode3 );
			
			streamBox.setVideoModes( desktopModes.mode );
			
		}
		
		protected function getVideoDeviceFormats():void {
			
			if ( !deviceQuery ) {
				
				deviceQuery = new DeviceInfoQuery( ffmpegFile );
				deviceQuery.addEventListener( Event.COMPLETE, deviceQueryComplete );
				
			}
			
			deviceQuery.queryVideoDevice( String( selectedVideoDevice ) );
			
		}
		
		protected function deviceQueryComplete( e:Event ):void {
			
			//trace( 'deviceQueryComplete', deviceQuery.xml );
			streamBox.setVideoModes( deviceQuery.xml.mode );
			
		}
		
		
		//
		// Misc
		//
		
		public function visitWebsite():void {
			
			visitLink( URLs.LINK_WEBSITE );
			
		}
		
		public function visitLink( s:String ):void {
			
			navigateToURL( new URLRequest( s ) ) ;
			
		}
		
		public function purchaseLicense():void {
			
			visitLink( URLs.LICENSE_PURCHASE );
			
		}
		
	}

}