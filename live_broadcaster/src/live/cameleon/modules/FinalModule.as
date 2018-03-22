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
 
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import live.cameleon.logger.LogEntry;
	import live.cameleon.logger.Logger;
	import mx.events.FlexEvent;
	import live.cameleon.settings.Application;
	import live.cameleon.views.LogWindow;
	
	public class FinalModule extends StreamerModule {
		
		public function FinalModule() {
			
			super();
			
		}
		
		override protected function init():void {
			
			super.init();
			mainWindow.module = this;
			ccWindow.module = this;
			
			//FileUtil.copyDirectory( File.applicationStorageDirectory, File.applicationStorageDirectory );
			
		}
		
		override protected function mainWindowComplete( e:FlexEvent ):void {
			
			super.mainWindowComplete(e);
			videoBox.module = this;
			youtubePanel.module = this;
			facebookPanel.module = this;
			mainWindow.helpWindow.module = this;
			mainWindow.proWindow.module = this;
			mainWindow.streamBox.videoBox.addEventListener( Event.VIDEO_FRAME, createStreamBitmap );
			header.toolTipText = "Core: " + config.coreVersionText + ", Module: " + Version.Major + "." + Version.Minor + "." + Version.Build + " " + Application.APP_NAME_ADDITION;
			
			var l:LogEntry = new LogEntry();
			l.level = Logger.LEVEL_INFO;
			l.category = Logger.CATEGORY_APPLICATION;
			l.text = "START";
			l.addChildObject( { text:"Core version: " + config.coreVersionText + ", Module version: " + Version.Major + "." + Version.Minor + "." + Version.Build + " " + Application.APP_NAME_ADDITION } );
			l.addChildObject( { text:"OS: " + Capabilities.os + ", 64Bit: " + Capabilities.supports64BitProcesses + ", 32bit: " + Capabilities.supports32BitProcesses } );
			l.addChildObject( { text:"CPU: " + Capabilities.cpuArchitecture } );
			l.addChildObject( { text:"Language: " + Capabilities.language } );
			l.addChildObject( { text:"Screen: " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY + ", " + Capabilities.screenDPI + "dpi, " + Capabilities.screenColor } );
			l.addChildObject( { text:"Install: " + File.applicationDirectory.nativePath } );
			
			Logger.addEntry( l );
			
		}
		
		override public function showLog():void {
			
			if ( !logWindow ) {
				
				logWindow = new LogWindow();
				logWindow.module = this;
				logWindow.cleanerFunction = resetWarnings;
				
			}
			
			super.showLog();
			
		}
		
		override protected function deviceListComplete( e:Event ):void {
			
			super.deviceListComplete(e);
			streamBox.setCameraSettings( cameraSettings );
			
		}
		
	}

}