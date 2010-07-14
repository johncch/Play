package org.fifthrevision.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class EditEvent extends Event {

		public static var MOVE:String = "move";
		public static var FONTSIZE:String = "fontSize";
		public static var DURATION:String = "duration";
		public static var IN:String = "in";
		public static var OUT:String = "out";
		
		public var params:Object;
		
		public function EditEvent(type:String, params:Object, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.params = params;			
		} 
		
		public override function clone():Event { 
			return new EditEvent(type, params, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("EditEvent", "type", "params", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}