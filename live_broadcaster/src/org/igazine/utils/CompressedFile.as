package org.igazine.utils {

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
	
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.utils.ByteArray;
	
	public class CompressedFile {
		
		private var _f:File;
		private var _fs:FileStream = new FileStream();
		private var _ba:ByteArray = new ByteArray();
		private var _index:DirectoryStructure = new DirectoryStructure();
		private var _path:String;
		private var _header:CompressedFileHeader = new CompressedFileHeader();
		
		public function CompressedFile(s:String) {
			_path = s;
			_f = File.documentsDirectory.resolvePath(_path);
		}
		
		public function load():void {
			
		}
		
		public function addFile(s:String):void {
			trace("Adding file: "+s);
			var f:SingleFile = new SingleFile(s);
			_index.addFile(f);
			_header.NUMBER_OF_FILES++;
		}
		
		public function compress():void {
			_ba.compress();
		}
		
		public function save(compressed:Boolean = true):void {
			trace("Starting compression...");
			var i:int;
			_header.COMPRESSED_HEADERS = true;			
			_fs.open(_f, FileMode.WRITE);
			
			// Writing header
			_fs.writeUTFBytes(_header.IDENTIFIER);
			_fs.writeShort(_header.VERSION);
			_fs.writeBoolean(_header.COMPRESSED_HEADERS);
			_fs.writeShort(_header.NUMBER_OF_FILES);
			
			// Writing Headers
			for (i=0;i<_index.files.length;i++) {
				_ba.writeShort(_index.files[i].header.NAME_LENGTH);
				_ba.writeUTFBytes(_index.files[i].header.NAME);
				_ba.writeInt(_index.files[i].header.SIZE);
				_ba.writeInt(_index.files[i].header.COMPRESSED_SIZE);
				//_ba.writeUTFBytes("POSITION:"+_index.files[i].header.POSITION.toString());
				_ba.writeInt(_index.files[i].header.POSITION);
				//_fs.writeBytes(_index.files[i].content);
				FilePosition.TOTAL_SIZE += _index.files[i].header.SIZE;
			}
			if (_header.COMPRESSED_HEADERS) _ba.compress();
			_fs.writeInt(_ba.length);
			//_fs.writeUTFBytes("HDRSIZE:"+_ba.length.toString());
			_fs.writeBytes(_ba);

			// Writing Files
			for (i=0;i<_index.files.length;i++) {
				_fs.writeBytes(_index.files[i].content);
			}
			trace("done.");
			trace("Original size: "+FilePosition.TOTAL_SIZE);
			trace("Compressed size: "+_f.size);
			trace("Ratio: "+(_f.size/FilePosition.TOTAL_SIZE));

			//_fs.writeBytes(_ba);
			_fs.close();
		}

	}
	
}
