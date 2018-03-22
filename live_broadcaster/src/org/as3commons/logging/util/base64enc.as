/*
 * Copyright (c) 2008-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.logging.util {
	
	import flash.utils.ByteArray;
	
	/**
	 * Encode a byte array using a 64 character table.
	 * 
	 * This implementation is based on the base64 encoder of Jean-Phillip Auclair.
	 * It has been modified to be Flash Player 9 and Flex compatible.
	 * 
	 * @param data ByteArray to be transformed to a BASE-64 encoded string
	 * @param start Start position from where to read from.
	 * @param length Amount of bytes to be read. 0 equals to the all available data.
	 *               If the length exceeds the size of data it will be trimmed.
	 * @param useLineBreak Use a 76 character line break
	 * @author Jean-Philippe Auclair
 	 * @author Martin Heidegger mh@leichtgewicht.at
 	 * @see http://en.wikipedia.org/wiki/Base64
 	 * @see http://www.sociodox.com/base64.html
	 */
	public function base64enc(data:ByteArray, start:uint=0, length:uint=0,
											useLineBreak:Boolean=true): String {
		
		var oldPosition: int = data.position;
		var end:int;
		
		// Check that the start and length are within the datas limit.
		if( start > data.length ) {
			start = data.length-1;
		} 
		if( length == 0 ) {
			end = data.length;
		} else {
			end = start + length;
			if( end > data.length ) {
				end = data.length;
			}
		}
		length = end - start;
		
		// Presetting the length keep the memory smaller and optimize speed since
		// there is no "grow" needed
		var outSize: int = (2 + length - ((length + 2) % 3)) * 4 / 3;
		if( useLineBreak ) {
			// Add the line breaks that will be written to the bytearray
			outSize += int(outSize/76);
		}
		// Reset the output bytearray
		OUT.position = 0;
		OUT.length = outSize;
		
		// The next part of the logic only works with 3character sets, the
		// overlapping characters need to be processed at the end.
		var over:int = length % 3;
		end -= over;
		
		var current:uint; //read (3) character AND write (4) characters
		var outPos:int = 0;
		// As the processing of linebreaks consume performance, linebreaks are
		// handled in a separate blocks.
		if( useLineBreak ) {
			var nextLineBreak: int = 76;
			while (start < end) {
				if( outPos == nextLineBreak ) {
					OUT[int(outPos++)] = 10;
					// The next linebreak is one character further (the linebreak
					// is also a character)
					nextLineBreak += 77;
				}
				//Read 3 Characters (8bit * 3 = 24 bits)  
				current = data[int(start++)] << 16 | data[int(start++)] << 8
						| data[int(start++)];
				
				OUT[int(outPos++)] = BASE[int(current >>> 18)];
				OUT[int(outPos++)] = BASE[int(current >>> 12 & 0x3f)];
				OUT[int(outPos++)] = BASE[int(current >>> 6 & 0x3f)];
				OUT[int(outPos++)] = BASE[int(current & 0x3f)];
			}
		} else {
			while (start < end) {
				//Read 3 Characters (8bit * 3 = 24 bits)
				current = data[int(start++)] << 16 | data[int(start++)] << 8
						| data[int(start++)];
				
				OUT[int(outPos++)] = BASE[int(current >>> 18)];
				OUT[int(outPos++)] = BASE[int(current >>> 12 & 0x3f)];
				OUT[int(outPos++)] = BASE[int(current >>> 6 & 0x3f)];
				OUT[int(outPos++)] = BASE[int(current & 0x3f)];
			}
		}
		
		// Need two "=" padding
		if (over == 1) {
			// Read one char, write two chars, write padding
			current = data[int(start)];
			
			// Pass the first part of the first character
			OUT[int(outPos++)] = BASE[int(current >>> 2)];
			// Pass the second part of the first character
			OUT[int(outPos++)] = BASE[int((current & 0x03) << 4)];
			// Two "=="
			OUT[int(outPos++)] = 61;
			OUT[int(outPos++)] = 61;
		} else if (over == 2) { //Need one "=" padding
			current = data[int(start++)] << 8 | data[int(start)];
			
			// Pass the first part of the first character
			OUT[int(outPos++)] = BASE[int(current >>> 10)];
			// Pass the second part of the first character
			OUT[int(outPos++)] = BASE[int(current >>> 4 & 0x3f)];
			OUT[int(outPos++)] = BASE[int((current & 0x0f) << 2)];
			// One "="
			OUT[int(outPos++)] = 61;
		}
		
		// Add the last linebreak if necessary
		if( useLineBreak && outPos > 0 && (outPos % 76) == 0 ) {
			OUT[int(outPos)] = 10;
		}
		
		// Reset the data position
		data.position = oldPosition;
		
		// Reset the position for reading the data
		OUT.position = 0;
		// Read the result (creates a string)
		var result: String = OUT.readUTFBytes(OUT.length);
		// Reset the ByteArray to release the memory
		OUT.length = 0;
		return result;
	}
}

import flash.utils.ByteArray;
const OUT: ByteArray = new ByteArray();
const BASE: Array = [65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,
					//A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T,
					 85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,
					//U, V, W, X, Y, Z, a, b, c,  d,  e,  f,  g,  h,  i,  j,  k,
					 108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,
					// l,  m,  n,  o,  p,  q,  r,  s,  t,  u,  v,  w,  x,  y,  z,
					 48,49,50,51,52,53,54,55,56,57,43,47];
					//0, 1, 2, 3, 4, 5, 6, 7, 8, 9, +, /];