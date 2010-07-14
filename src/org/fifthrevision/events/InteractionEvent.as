package org.fifthrevision.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Chua Chong Han
	 */
	public class InteractionEvent extends Event {
		
		public static const NEXT:String = "next";
		public static const PREV:String = "prev";
		public static const CANCEL_AND_NEXT:String = "cancelAndNext";
		public static const CANCEL_AND_PREV:String = "cancelAndPrev";
		
		public function InteractionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);			
		} 
		
		public override function clone():Event { 
			return new InteractionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("InteractionEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}