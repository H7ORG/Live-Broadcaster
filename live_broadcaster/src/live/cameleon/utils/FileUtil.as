package live.cameleon.utils {

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
	
	public class FileUtil {
		
		public function FileUtil() {}
		
		public static function copyDirectory( source:File, destination:File, overwrite:Boolean = true ):void {
			
			if ( source.exists ) {
				
				var sourceFiles:Array = generateFileList( source );
				
			}
			
		}
		
		private static function generateFileList( directory:File ):Array {
			
			var fileList:Array = directory.getDirectoryListing();
			var i:int = 0;
			var l:int;
			
			l = fileList.length;
			
			while ( i < l ) {
				
				if ( fileList[i].isDirectory ) fileList = fileList.concat( getDirectoryList( fileList[i] ) );
				l = fileList.length;
				i++;
				
			}
			
			//for ( i = 0; i < fileList.length; i++ ) trace( "\t\t\t\t", fileList[i].nativePath, fileList[i].isDirectory );
			
			return fileList;
			
		}
		
		private static function getDirectoryList( directory:File ):Array {
			
			return directory.getDirectoryListing();
			
		}
		
	}

}