package org.igazine.apis.googledrive {
	
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
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import org.igazine.apis.googledrive.resources.*;
	import com.adobe.serialization.json.JSON;
	import org.igazine.apis.googledrive.events.FileResourceEvent;
	
	public class GoogleDrive extends EventDispatcher {
		
		private static const ABOUT:String = "https://www.googleapis.com/drive/v3/about";
		private static const FILES:String = "https://www.googleapis.com/drive/v3/files";
		private static const UPLOAD:String = "https://www.googleapis.com/upload/drive/v3/files";
		private static const GENERATE_IDS:String = "https://www.googleapis.com/drive/v3/files/generateIds";
		
		private var token:String;
		private var headers:Array;
		private var filesToDelete:Array;
		private var numFilesDeleted:int;
		private var tempFile:FileResource;
		
		public function GoogleDrive( target:flash.events.IEventDispatcher = null ) {
			
			super(target);
			
		}
		
		private function ldrComplete( e:Event ):void {
			
			//trace( "ldrComplete", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, ldrComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, ldrError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			
		}
		
		private function ldrError( e:IOErrorEvent ):void {
			
			//trace( "ldrError", e.errorID, e.target.data );
			e.target.removeEventListener( Event.COMPLETE, ldrComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, ldrError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			
		}
		
		private function ldrStatus( e:HTTPStatusEvent ):void {
			
			//trace( "ldrStatus", e.status );
			
		}
		
		//
		// Public functions
		// 
		
		public function about():void {
			
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( ABOUT + "?fields=appInstalled" );
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			ldr.addEventListener( Event.COMPLETE, ldrComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, ldrError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, ldrStatus );
			ldr.load( req );
			
		}
		
		public function fileList( q:String = undefined, strict:Boolean = true ):void {
			
			var fileListLoader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( FILES );
			var vars:URLVariables = new URLVariables();
			vars.spaces = "appDataFolder";
			
			if ( q ) {
				
				if ( strict ) {
					
					vars.q = "name='" + q + "'";
					
				} else {
					
					vars.q = "name contains '" + q + "'";
					
				}
				
			}
			
			req.data = vars;
			
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			fileListLoader.addEventListener( Event.COMPLETE, fileListLoaderComplete );
			fileListLoader.addEventListener( IOErrorEvent.IO_ERROR, fileListLoaderError );
			fileListLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, fileListLoaderStatus );
			fileListLoader.load( req );
			
		}
		
		private function fileListLoaderComplete( e:Event ):void {
			
			//trace( "fileListLoaderComplete", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, fileListLoaderComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, fileListLoaderError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, fileListLoaderStatus );
			var result:Object = com.adobe.serialization.json.JSON.decode( String( e.target.data ) );
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.FILE_FOUND );
			evt.files = result.files;
			this.dispatchEvent( evt );
			
		}
		
		private function fileListLoaderError( e:IOErrorEvent ):void {
			
			//trace( "fileListLoaderError", e.errorID, e.target.data );
			e.target.removeEventListener( Event.COMPLETE, fileListLoaderComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, fileListLoaderError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, fileListLoaderStatus );
			
		}
		
		private function fileListLoaderStatus( e:HTTPStatusEvent ):void {
			
			//trace( "fileListLoaderStatus", e.status );
			
		}
		
		public function generateIds( count:int = 1, space:String = "appDataFolder" ):void {
			
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( GENERATE_IDS + "?count=" + String( count ) + "&space=" + space );
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			ldr.addEventListener( Event.COMPLETE, idLoaderComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, idLoaderError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, idLoaderStatus );
			ldr.load( req );
			
		}
		
		private function idLoaderComplete( e:Event ):void {
			
			trace( "idLoaderComplete", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, idLoaderComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, idLoaderError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, idLoaderStatus );
			
			var o:Object = com.adobe.serialization.json.JSON.decode( String( e.target.data ) );
			
			var f:FileResource = new FileResource();
			//f.id = o.ids[0];
			//f.addSpace( o.space );
			
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.ID_GENERATED );
			evt.file = f;
			this.dispatchEvent( evt );
			
		}
		
		private function idLoaderError( e:IOErrorEvent ):void {
			
			//trace( "idLoaderError", e.errorID );
			e.target.removeEventListener( Event.COMPLETE, idLoaderComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, idLoaderError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, idLoaderStatus );
			
		}
		
		private function idLoaderStatus( e:HTTPStatusEvent ):void {
			
			//trace( "idLoaderStatus", e.status );
			
		}
		
		public function uploadMultipart( file:FileResource, overwrite:Boolean = false ):void {
			
			if ( overwrite ) {
				
				uploadMultipartOverwrite( file );
				
			} else {
				
				uploadMultipartVersion( file );
				
			}
			
		}
		
		private function uploadMultipartOverwrite( file:FileResource ):void {
			
			tempFile = file;
			
			var fileListLoader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( FILES );
			var vars:URLVariables = new URLVariables();
			vars.spaces = "appDataFolder";
			vars.q = "name='" + file.name + "'";
			req.data = vars;
			
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			fileListLoader.addEventListener( Event.COMPLETE, uploadMultipartOverwriteFileListLoaderComplete );
			fileListLoader.addEventListener( IOErrorEvent.IO_ERROR, uploadMultipartOverwriteFileListLoaderError );
			fileListLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, uploadMultipartOverwriteFileListLoaderStatus );
			fileListLoader.load( req );
			
		}
		
		private function uploadMultipartOverwriteFileListLoaderComplete( e:Event ):void {
			
			//trace( "fileListLoaderComplete", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, uploadMultipartOverwriteFileListLoaderComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, uploadMultipartOverwriteFileListLoaderError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, uploadMultipartOverwriteFileListLoaderStatus );
			var result:Object = com.adobe.serialization.json.JSON.decode( String( e.target.data ) );
			filesToDelete = result.files;
			numFilesDeleted = 0;
			
			this.addEventListener( FileResourceEvent.DELETED, uploadMultipartOverwriteFileListLoaderDeleteComplete );
			this.addEventListener( FileResourceEvent.ERROR, uploadMultipartOverwriteFileListLoaderDeleteError );
			
			for ( var i:int = 0; i < filesToDelete.length; i++ ) {
				
				var f:FileResource = new FileResource();
				f.id = filesToDelete[i].id;
				this.deleteFile( f );
				
			}
			
			if ( filesToDelete.length == 0 ) {
				
				continueUploadMultipartOverwrite();
				
			}
			
		}
		
		private function uploadMultipartOverwriteFileListLoaderDeleteComplete( e:FileResourceEvent ):void {
			
			numFilesDeleted++;
			
			if ( numFilesDeleted >= filesToDelete.length ) continueUploadMultipartOverwrite();
			
		}
		
		private function uploadMultipartOverwriteFileListLoaderDeleteError( e:FileResourceEvent ):void {
			
			numFilesDeleted++;
			
			if ( numFilesDeleted >= filesToDelete.length ) continueUploadMultipartOverwrite();
			
		}
		
		private function continueUploadMultipartOverwrite():void {
			
			this.removeEventListener( FileResourceEvent.DELETED, uploadMultipartOverwriteFileListLoaderDeleteComplete );
			this.removeEventListener( FileResourceEvent.ERROR, uploadMultipartOverwriteFileListLoaderDeleteError );
			
			uploadMultipartVersion( tempFile );
			
		}
		
		private function uploadMultipartOverwriteFileListLoaderError( e:Event ):void {
			
			e.target.removeEventListener( Event.COMPLETE, uploadMultipartOverwriteFileListLoaderComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, uploadMultipartOverwriteFileListLoaderError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, uploadMultipartOverwriteFileListLoaderStatus );
			
		}
		
		private function uploadMultipartOverwriteFileListLoaderStatus( e:Event ):void {}
		
		private function uploadMultipartVersion( file:FileResource ):void {
			
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( UPLOAD + "?uploadType=multipart" );
			req.method = URLRequestMethod.POST;
			req.requestHeaders = headers;
			req.contentType = "multipart/related; boundary=" + FileResource.BOUNDARY;
			
			var lineEnd:String = "\n";
			var s:String = FileResource.BOUNDARY_FULL + lineEnd;
			s += "Content-Type: application/json; charset=UTF-8" + lineEnd + lineEnd;
			s += file.metadata + lineEnd + lineEnd;
			s += FileResource.BOUNDARY_FULL + lineEnd;
			s += "Content-Type: text/plain; charset=UTF-8" + lineEnd + lineEnd;
			s += file.content + lineEnd + lineEnd;
			s += FileResource.BOUNDARY_FULL + "--";
			req.data = s;
			
			req.requestHeaders.push( new URLRequestHeader( "Content-Length", String( s.length + 10 ) ) );
			
			//trace( req.data );
			
			ldr.addEventListener( Event.COMPLETE, uploadComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, uploadError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, uploadStatus );
			ldr.load( req );
			
			
		}
		
		private function uploadComplete( e:Event ):void {
			
			//trace( "uploadComplete", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, uploadComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, uploadError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, uploadStatus );
			
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.UPLOADED );
			this.dispatchEvent( evt );
			
		}
		
		private function uploadError( e:IOErrorEvent ):void {
			
			//trace( "uploadError", e.errorID, e.target.data );
			e.target.removeEventListener( Event.COMPLETE, uploadComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, uploadError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, uploadStatus );
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.ERROR );
			this.dispatchEvent( evt );
			
		}
		
		private function uploadStatus( e:HTTPStatusEvent ):void {
			
			//trace( "uploadStatus", e.status );
			
		}
		
		public function deleteFile( file:FileResource ):void {
			
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( FILES + "/" + file.id );
			req.method = URLRequestMethod.DELETE;
			req.requestHeaders = headers;
			
			ldr.addEventListener( Event.COMPLETE, deleteComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, deleteError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, deleteStatus );
			ldr.load( req );
			
		}
		
		private function deleteComplete( e:Event ):void {
			
			//trace( "deleteComplete", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, deleteComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, deleteError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, deleteStatus );
			
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.DELETED );
			this.dispatchEvent( evt );
			
		}
		
		private function deleteError( e:IOErrorEvent ):void {
			
			//trace( "deleteError", e.errorID, e.target.data );
			e.target.removeEventListener( Event.COMPLETE, deleteComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, deleteError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, deleteStatus );
			
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.ERROR );
			this.dispatchEvent( evt );
			
		}
		
		private function deleteStatus( e:HTTPStatusEvent ):void {
			
			//trace( "deleteStatus", e.status );
			
		}
		
		public function getFile( file:FileResource ):void {
			
			var ldr:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest( FILES + "/" + file.id + "?alt=media" );
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			
			ldr.addEventListener( Event.COMPLETE, getComplete );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, getError );
			ldr.addEventListener( HTTPStatusEvent.HTTP_STATUS, getStatus );
			ldr.load( req );
			
		}
		
		private function getComplete( e:Event ):void {
			
			//trace( "getComplete", e.target.data );
			e.target.removeEventListener( Event.COMPLETE, getComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, getError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, getStatus );
			
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.DOWNLOADED );
			evt.content = String( e.target.data );
			this.dispatchEvent( evt );
			
		}
		
		private function getError( e:IOErrorEvent ):void {
			
			//trace( "getError", e.errorID, e.target.data );
			e.target.removeEventListener( Event.COMPLETE, getComplete );
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, getError );
			e.target.removeEventListener( HTTPStatusEvent.HTTP_STATUS, getStatus );
			
			var evt:FileResourceEvent = new FileResourceEvent( FileResourceEvent.ERROR );
			this.dispatchEvent( evt );
			
		}
		
		private function getStatus( e:HTTPStatusEvent ):void {
			
			//trace( "getStatus", e.status );
			
		}
		
		//
		// Getters and Setters
		//
		
		public function get accessToken():String {
			
			return token;
			
		}
		
		public function set accessToken( s:String ):void {
			
			token = s;
			var hdr:URLRequestHeader = new URLRequestHeader( "Authorization", "Bearer " + token );
			headers = new Array( hdr );
			
		}
		
	}

}