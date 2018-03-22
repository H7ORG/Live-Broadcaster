package live.cameleon.net.cameleoncenter {

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
 
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import live.cameleon.system.Os;
	
	public class CameleonCenterHelper {
		
		private static const CAMELEON_CENTER_APP_ID:String = "live.cameleon.cameleoncenter";
		private static const CAMELEON_CENTER_APP_ID_LOCAL_STORE:String = "Local Store";
		private static const CAMELEON_CENTER_INI_FILE:String = "CameleonCenter.ini";
		private static const CAMELEON_CENTER_DATA_DIR:String = "www";
		
		private static var _storagePath:File;
		private static var _settings:Object;
		private static var _installPath:File;
		private static var _dataPath:File;
		
		public function CameleonCenterHelper() {}
		
		public static function get storagePath():File {
			
			if ( !_storagePath ) {
				
				var p:String = File.applicationStorageDirectory.nativePath;
				var a:Array = p.split( Os.pathDivider );
				var np:String = "";
				
				for ( var i:int = 0; i < a.length - 2; i++ ) {
				
					np += a[i] + Os.pathDivider;
					
				}
				
				np += CAMELEON_CENTER_APP_ID + Os.pathDivider + CAMELEON_CENTER_APP_ID_LOCAL_STORE;
				
				trace( np );
				
				var f:File = new File( np );
				_storagePath = f;
				return f;
				
			}
			
			return _storagePath;
			
		}
		
		public static function get settings():Object {
			
			if ( _settings ) return _settings;
			
			var o:Object;
			
			if ( storagePath.exists ) {
				
				var f:File = storagePath.resolvePath( "settings" );
				if ( f.exists ) {
					
					var fs:FileStream = new FileStream();
					var ba:ByteArray = new ByteArray();
					
					try {
						
						fs.open( f, FileMode.READ );
						fs.readBytes( ba );
						fs.close();
						
					} catch ( e:Error ) {}
					
					if ( ba && ba.length > 0 ) {
						
						try {
							
							o = ba.readObject();
							
						} catch( e:Error ) {}
						
					}
					
				}
				
			}
			
			_settings = o;
			return o;
			
		}
		
		public static function get installPath():File {
			
			if ( _installPath ) return _installPath;
			
			// Checking INI file on Windows
			if ( Os.isWindows ) {
				
				var iniFile:File = File.userDirectory.resolvePath( CAMELEON_CENTER_INI_FILE );
				
				if ( iniFile.exists  ) {
					
					var iniStream:FileStream = new FileStream();
					var iniBytes:ByteArray = new ByteArray();
					var iniString:String;
					
					try {
						
						iniStream.open( iniFile, FileMode.READ );
						iniString = iniStream.readUTFBytes( iniFile.size );
						iniStream.close();
						
					} catch ( e:Error ) {}
					
					if ( iniString ) {
						
						var iniArray:Array = iniString.split( Os.lineEnd );
						trace( iniArray );
						
						for ( var j:int = 0; j < iniArray.length; j++ ) {
							
							if ( iniArray[j].search( "installdir" ) >= 0 ) {
								
								var installArray:Array = iniArray[j].split( "=" );
								_installPath = new File( installArray[1] );
								return _installPath;
								
							}
							
						}
						
					}
					
				}
				
			}
			
			// Checking for settings file only on Windows
			if ( settings && settings.installPath && Os.isWindows ) {
				
				_installPath = new File( settings.installPath );
				return _installPath;
				
			}
			
			// Checking on macOS if settings file is not present
			var f:File = new File( "/Applications/cameleon.live" );
			return f;
			
			return null;
			
		}
		
		public static function get executable():File {
			
			if ( Os.isMac ) return installPath.resolvePath( "Cameleon Center.app" );
			return installPath.resolvePath( "Cameleon Center.exe" );
			
		}
		
		public static function get dataPath():File {
			
			if ( _dataPath ) return _dataPath;
			
			if ( storagePath ) {
				
				_dataPath = storagePath.resolvePath( CAMELEON_CENTER_DATA_DIR );
				return _dataPath;
				
			}
			
			return null;
			
		}
		
	}

}