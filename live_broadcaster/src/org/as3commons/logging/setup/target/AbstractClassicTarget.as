package org.as3commons.logging.setup.target {
	import org.as3commons.logging.api.ILogTarget;
	/**
	 * <code>AbstractClassicTarget</code>
	 *
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @since
	 */
	public class AbstractClassicTarget implements ILogTarget {
		
		/** Regular expression used to transform the value */
		private static const _fieldRegexp: RegExp = /{(([\w_]+\.?)*)}/ig;
		
		private var _params:Array;
		private var _posPair:Object;
		private var _value:*;
		private var _cnt:int;
		
		public final function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:*,
							person:String, context:String, shortContext:String):void {
			
			// AS3 commons logging format: {abcdef}
			// Flex logging format: {0}
			_value = parameters;
			_cnt = -1;
			
			if( message ) {
				message = message.replace(_fieldRegexp, replaceMessageEntries);
			} else {
				message = "";
			}
			doLog(name, shortName, level, timeStamp, message, _params, person,
					context, shortContext);
			_params = null;
			_posPair = null;
			_value = null;
		}
		
		protected function doLog(name:String, shortName:String, level:int,
							timeStamp:Number, message:String, parameters:Array,
							person:String, context:String, shortContext:String): void {
			throw new Error("abstract");
		}
		
		/**
		 * Replaces the messages in the string and fills the new Array with the necessary
		 * new parameters.
		 */
		private function replaceMessageEntries(encapsulated: String,  field: String, no: int, len: int, intext: String):String {
			var d: String = field;
			var pos: String = (_posPair||={})[field];
			var value: *;
			if( !pos ) {
				value = _value;
				if( field != "" ) {
					
					var start: int = 0;
					var end: int;
					while( value != null ) {
						end = field.indexOf(".", start);
						if( end == -1 ) {
							try {
								value = value[d];
							} catch( e: * ) {
								value = e;
							}
							break;
						} else {
							d = field.substring(start, end);
							start = end+1;
							try {
								value = value[d];
							} catch( e: * ) {
								value = e;
								break;
							}
						}
					}
				}
				(_params||=[])[ ++_cnt ]= value;
				pos = _posPair[field] = "{"+_cnt+"}";
			}
			return pos;
		}
	}
}
