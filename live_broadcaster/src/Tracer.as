package {
	
	public class Tracer {
		
		public function Tracer() {}
		
		public static var enabled:Boolean;
		
		public static function log( ...rest ):void {
			
			if ( enabled ) {
				
				var s:String = "";
				for each( var item:* in rest ) s += item + " ";
				trace( s );
				
			}
			
		}
		
	}

}