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

package org.igazine.nativeprocess.encoder.codecs {
	
	import org.igazine.nativeprocess.encoder.parameters.IParameterSet;
	
	public class AudioCodec implements IParameterSet {
		
		public static const CODEC_COPY:String = "copy";
		//public static const CODEC_AAC:String = "libvo_aacenc";
		public static const CODEC_AAC:String = "aac";
		public static const CODEC_MP3:String = "libmp3lame";
		public static const CODEC_SPEEX:String = "speex";
		public static const CODEC_NELLYMOSER:String = "nellymoser";
		
		protected var name:String;
		
		public var sampleRate:int;
		public var bandwidth:int;
		public var channels:int;
		
		public function AudioCodec() {
			
			this.name = CODEC_COPY;
			//-acodec libvo_aacenc -ar 44100 -b:a 92k 
			
		}
		
		/* INTERFACE org.igazine.nativeprocess.encoder.parameters.IParameterSet */
		
		public function get parameters():Vector.<String> {
			
			var p:Vector.<String> = new Vector.<String>();
			
			p.push( "-c:a", this.name );
			if ( sampleRate ) p.push( "-ar", String( sampleRate ) );
			if ( bandwidth ) p.push( "-b:a", String( bandwidth ) + "k" );
			if ( channels ) p.push( "-ac", String( channels ) );
			if ( this.name == CODEC_AAC ) p.push( "-bsf:a", "aac_adtstoasc" );
			
			return p;
			
		}
		
	}

}