package {

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
	import flash.display.BitmapData;
	import flash.events.UncaughtErrorEvent;
	import live.cameleon.modules.FinalModule;
	import mx.events.FlexEvent;
	import live.cameleon.settings.BindableSettings;
	import spark.components.Window;
	import live.cameleon.views.HelpWindow;
	import live.cameleon.views.SettingsWindow;
	import live.cameleon.views.ProWindow;
	
	public class MainWindowBase extends Window {
		
		// Parent
		protected var parentApp:NativeApplication;
		public var module:FinalModule;
		//[Bindable] public var processing:Boolean;
		private var _processing:Boolean;
		
		// Log helpers
		[Bindable] public var hasError:Boolean;
		[Bindable] public var hasWarning:Boolean;
		
		// Window properties
		public var maximized:Boolean;
		protected var isMouseDown:Boolean;
		[Bindable] protected var windowTitle:String = "Live Broadcaster";
		
		// View Properties
		[Bindable] public var youtubeState:String = "loggedOut";
		[Bindable] public var broadcastTitle:String = "My Live Broadcast";
		[Bindable] public var broadcastDescription:String = "";
		[Bindable] public var defaultYouTubeLiveBroadcastId:String;
		[Bindable] public var defaultYouTubeLiveStreamId:String;
		[Bindable] public var connected:Boolean;
		[Bindable] public var connecting:Boolean;
		[Bindable] public var zoom:Boolean;
		[Bindable] public var fbCompatible:Boolean;
		[Bindable] public var canStart:Boolean;
		
		public var settingsWindow:SettingsWindow;
		public var helpWindow:HelpWindow;
		public var proWindow:ProWindow;
		
		// Server properties
		[Bindable] public var serverState:String;
		
		public function MainWindowBase() {
			
			super();
			
			this.showStatusBar = false;
			this.width = this.minWidth = 1240;
			this.height = this.minHeight = 700;
			this.systemChrome = "none";
			this.transparent = true;
			
			settingsWindow = new SettingsWindow();
			helpWindow = new HelpWindow();
			proWindow = new ProWindow();
			
			this.addEventListener( FlexEvent.CREATION_COMPLETE, init );
			
		}
		
		protected function init( e:FlexEvent ):void {
			
			this.loaderInfo.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError );
			
		}
		
		protected function uncaughtError( e:UncaughtErrorEvent ):void {}
		
		//
		// Window Handlers
		//
		
		public function minimizeApp():void {
			
			this.minimize();
			
		}
		
		public function maximizeApp( altKey:Boolean = false ):void {
			
			if ( !maximized ) {
				
				this.maximize();
				BindableSettings.MAIN_WINDOW_PADDING = 0;
				
			} else {
				
				this.restore();
				BindableSettings.MAIN_WINDOW_PADDING = 10;
				
			}
			
			maximized = !maximized;
			
		}
		
		protected function onMouseMove():void {}
		
		protected function onMouseDown():void {
			
			isMouseDown = true;
			this.nativeWindow.startMove();
		
		}
		
		protected function onMouseUp():void {
			
			isMouseDown = false;
		
		}
		
		public function resizerMouseDown():void {
			
			this.nativeWindow.startResize("BR");
			
		}
		
		public function resizerMouseUp():void { }
		
		//
		// Device functions
		//
		
		public function getStreamBitmapData():BitmapData {
			
			return null;
			
		}
		
		//
		// Window functions
		//
		
		public function showSettings():void {
			
			settingsWindow.show( this );
			
		}
		
		public function showHelp():void {
			
			helpWindow.show( this );
			
		}
		
		public function showPro():void {
			
			proWindow.show( this );
			
		}
		
		//
		// Getters and Setters
		//
		
		[Bindable]
		public function get processing():Boolean { return _processing; }
		
		public function set processing( value:Boolean ):void {
			
			_processing = value;
			
		}
		
	}

}